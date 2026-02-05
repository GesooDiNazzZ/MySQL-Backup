FROM debian:bookworm-slim

# Install python and basic dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    gnupg \
    lsb-release \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add MySQL GPG key and repository manually
RUN wget -qO - https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 | gpg --dearmor > /etc/apt/trusted.gpg.d/mysql.gpg \
    && echo "deb http://repo.mysql.com/apt/debian/ $(lsb_release -sc) mysql-8.0" > /etc/apt/sources.list.d/mysql.list \
    && apt-get update \
    && apt-get install -y mysql-community-client \
    && rm -rf /var/lib/apt/lists/*

# Create directory for the application
WORKDIR /app

# Create virtual environment and install dependencies
# We use --break-system-packages because we are in a container and it's safe
COPY requirements.txt .
RUN pip3 install --break-system-packages --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Ensure backup directory exists
RUN mkdir -p backups

# Set the entrypoint command
CMD ["python3", "main.py"]
