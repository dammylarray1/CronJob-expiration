# Start from the official PowerShell image
FROM mcr.microsoft.com/powershell:7.3.2-debian-11-slim

# Set up the working directory in the container
WORKDIR /app

# Copy the PowerShell script into the container
COPY check_expiration.ps1 /app/check_expiration.ps1

# Set the entrypoint to run the PowerShell script
ENTRYPOINT ["pwsh", "/app/check_expiration.ps1"]
