FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    mysql-client-8.0 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user 'container' which Pterodactyl expects
RUN useradd -m -d /home/container -s /bin/bash container

# Set working directory to /home/container (standard for Pterodactyl)
WORKDIR /home/container

# Copy requirements and install python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Fix permissions: Give ownership of everything to the 'container' user
RUN chown -R container:container /home/container

# Switch to the non-root user
USER container

# Ensure backup directory exists (it will be created by the script, but good practice)
RUN mkdir -p backups

# Set the entrypoint command
CMD ["python3", "main.py"]
