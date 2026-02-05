FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add MySQL GPG key and repository manually to avoid interactive config errors
# We use the 2023 key which is the current one for MySQL 8.0 repositories
RUN wget -qO - https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 | gpg --dearmor > /etc/apt/trusted.gpg.d/mysql.gpg \
    && echo "deb http://repo.mysql.com/apt/debian/ $(lsb_release -sc) mysql-8.0" > /etc/apt/sources.list.d/mysql.list \
    && apt-get update \
    && apt-get install -y mysql-community-client \
    && rm -rf /var/lib/apt/lists/*

# Create directory for the application
WORKDIR /app

# Copy requirements and install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Ensure backup directory exists
RUN mkdir -p backups

# Set the entrypoint command
CMD ["python", "main.py"]
