import os
import datetime
import subprocess
import mysql.connector
import gzip
import shutil
from dotenv import load_dotenv

# Carica le variabili d'ambiente
load_dotenv()

# Configurazione
DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
BACKUP_DIR = os.getenv("BACKUP_DIR", "backups")
RETENTION_DAYS = int(os.getenv("RETENTION_DAYS", 7))

def get_database_list():
    """Recupera la lista di tutti i database presenti."""
    try:
        conn = mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD
        )
        cursor = conn.cursor()
        cursor.execute("SHOW DATABASES")
        
        databases = []
        excluded_dbs = ['information_schema', 'performance_schema', 'sys']
        
        for (db_name,) in cursor:
            if db_name not in excluded_dbs:
                databases.append(db_name)
                
        cursor.close()
        conn.close()
        return databases
    except mysql.connector.Error as err:
        print(f"Errore durante la connessione al database: {err}")
        return []

def backup_database(db_name, timestamp):
    """Esegue il backup di un singolo database usando mysqldump."""
    filename = f"{db_name}_{timestamp}.sql"
    filepath = os.path.join(BACKUP_DIR, filename)
    gz_filepath = filepath + ".gz"

    print(f"Backup del database '{db_name}' in corso...")
    
    # Costruisci il comando mysqldump
    # --events: include eventi programmati
    # --routines: include procedure e funzioni salvate
    # --triggers: include trigger
    # --single-transaction: evita il blocco delle tabelle (per InnoDB)
    cmd = [
        "mysqldump",
        f"-h{DB_HOST}",
        f"-u{DB_USER}",
        f"-p{DB_PASSWORD}",
        "--events",
        "--routines",
        "--triggers",
        "--single-transaction",
        db_name
    ]

    try:
        with open(filepath, "w") as f:
            subprocess.check_call(cmd, stdout=f)
        
        # Comprimi il file
        with open(filepath, 'rb') as f_in:
            with gzip.open(gz_filepath, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        
        # Rimuovi il file .sql non compresso
        os.remove(filepath)
        print(f"Backup completato: {gz_filepath}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Errore durante il dump di {db_name}: {e}")
        if os.path.exists(filepath):
            os.remove(filepath)
        return False
    except Exception as e:
        print(f"Errore generico su {db_name}: {e}")
        return False

def clean_old_backups():
    """Rimuove i backup più vecchi di RETENTION_DAYS."""
    print("Pulizia vecchi backup...")
    now = datetime.datetime.now()
    cutoff = now - datetime.timedelta(days=RETENTION_DAYS)
    
    for filename in os.listdir(BACKUP_DIR):
        file_path = os.path.join(BACKUP_DIR, filename)
        if os.path.isfile(file_path):
            file_time = datetime.datetime.fromtimestamp(os.path.getmtime(file_path))
            if file_time < cutoff:
                print(f"Rimozione vecchio backup: {filename}")
                os.remove(file_path)

def main():
    if not all([DB_HOST, DB_USER, DB_PASSWORD]):
        print("Errore: Variabili d'ambiente DB_HOST, DB_USER, DB_PASSWORD mancanti.")
        return

    # Crea la cartella backup se non esiste
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)

    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    print(f"--- Inizio procedura backup: {timestamp} ---")

    databases = get_database_list()
    if not databases:
        print("Nessun database trovato o impossibile connettersi.")
        return

    print(f"Trovati {len(databases)} database: {', '.join(databases)}")

    for db in databases:
        backup_database(db, timestamp)

    clean_old_backups()
    print("--- Procedura completata ---")

if __name__ == "__main__":
    main()
