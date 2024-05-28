#!/bin/bash

# Créer un fichier de log
LOG_FILE="/var/log/initsetup.log"

echo "Début du script de configuration" | sudo tee -a $LOG_FILE

# Installation de CrowdSec
echo "Installation de CrowdSec..." | sudo tee -a $LOG_FILE
curl -s https://install.crowdsec.net | sudo sh | sudo tee -a $LOG_FILE
sudo apt install -y crowdsec | sudo tee -a $LOG_FILE
sudo apt install -y crowdsec-firewall-bouncer | sudo tee -a $LOG_FILE

# # Ajout du bouncer CrowdSec
# echo "Ajout du bouncer pour CrowdSec..." | sudo tee -a $LOG_FILE
# API_KEY=$(sudo cscli bouncers add fwBouncer | grep 'Api key for' | cut -d':' -f2 | xargs)
# echo "API Key récupérée: $API_KEY" | sudo tee -a $LOG_FILE

# Configuration du bouncer
# echo "Configuration du bouncer..." | sudo tee -a $LOG_FILE
# sudo sed -i "s/api_key: your_api_key/api_key: $API_KEY/" /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml | sudo tee -a $LOG_FILE

# Installation de Docker
echo "Installation de Docker..." | sudo tee -a $LOG_FILE
sudo apt-get install -y ca-certificates curl gnupg lsb-release | sudo tee -a $LOG_FILE
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release; echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update | sudo tee -a $LOG_FILE
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin | sudo tee -a $LOG_FILE

# Tester Docker
echo "Test de Docker avec l'exécution de hello-world..." | sudo tee -a $LOG_FILE
sudo docker run hello-world | sudo tee -a $LOG_FILE

echo "Configuration terminée avec succès!" | sudo tee -a $LOG_FILE
