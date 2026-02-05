FROM python:3.11-slim

# Install system dependencies
# We add the official MySQL repository to ensure we get the Oracle MySQL client, not MariaDB
RUN apt-get update && apt-get install -y \
    wget \
    lsb-release \
    gnupg \
    && wget https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb \
    && dpkg -i mysql-apt-config_0.8.28-1_all.deb \
    || (echo "mysql-apt-config installation failed expectedly (interactive), forcing non-interactive setup" \
    && export DEBIAN_FRONTEND=noninteractive \
    && echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections \
    && echo "mysql-apt-config mysql-apt-config/select-product select Ok" | debconf-set-selections \
    && dpkg -i mysql-apt-config_0.8.28-1_all.deb) \
    && apt-get update \
    && apt-get install -y mysql-community-client \
    && rm -rf /var/lib/apt/lists/* \
    && rm mysql-apt-config_0.8.28-1_all.deb

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
