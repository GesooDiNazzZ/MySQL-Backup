#!/bin/bash
# startup.sh - Script di avvio per Pterodactyl
# Se usi un'immagine standard Python e non hai root, questo potrebbe fallire.
# L'ideale è usare l'immagine Docker personalizzata creata.

echo "--- Avvio Backup System ---"

# Installa dipendenze python
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# Esegui lo script
python main.py

echo "--- Backup Completato ---"
