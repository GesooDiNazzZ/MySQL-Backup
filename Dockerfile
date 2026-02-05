FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
# Ubuntu 22.04 includes mysql-client-8.0 in its default repositories.
# This avoids the need for external Oracle repositories and GPG keys.
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    mysql-client-8.0 \
    && rm -rf /var/lib/apt/lists/*

# Create directory for the application
WORKDIR /app

# Copy requirements and install python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Ensure backup directory exists
RUN mkdir -p backups

# Set the entrypoint command
CMD ["python3", "main.py"]
