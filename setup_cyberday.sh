#!/bin/bash

# Créer un fichier de log
LOG_FILE="/var/log/initsetup.log"

echo "Début du script de configuration" | sudo tee -a $LOG_FILE

# Installation de CrowdSec
echo "Installation de CrowdSec..." | sudo tee -a $LOG_FILE
curl -s https://install.crowdsec.net | sudo sh | sudo tee -a $LOG_FILE
sudo apt install -y crowdsec | sudo tee -a $LOG_FILE
sudo apt install -y crowdsec-firewall-bouncer-iptables | sudo tee -a $LOG_FILE

# Clonage du dépôt Git pour CrowdSec custom parsers et scénarios
echo "Clonage du dépôt Git..." | sudo tee -a $LOG_FILE
sudo git clone https://github.com/Killian-Aidalinfo/cyberday-cs-custom /home/debian/cyberday-cs-custom | sudo tee -a $LOG_FILE
cd /home/debian/cyberday-cs-custom/cs-custom-security

# Copie des parsers et scénarios personnalisés de CrowdSec
echo "Copie des parsers et scénarios personnalisés..." | sudo tee -a $LOG_FILE
sudo cp parsers-bf-couchdb.yaml /etc/crowdsec/parsers/s01-parse | sudo tee -a $LOG_FILE
sudo cp scenario-bf-couchdb.yaml /etc/crowdsec/scenarios | sudo tee -a $LOG_FILE

# Préparation de la configuration de CouchDB
echo "Préparation de la configuration de CouchDB..." | sudo tee -a $LOG_FILE
sudo mkdir -p /etc/couchdb | sudo tee -a $LOG_FILE
sudo mkdir -p /etc/couchdb/config | sudo tee -a $LOG_FILE
sudo cp /home/debian/cyberday-cs-custom/config-couchdb/local.ini /etc/couchdb/config | sudo tee -a $LOG_FILE

# Installation de Docker
echo "Installation de Docker..." | sudo tee -a $LOG_FILE
sudo apt-get install -y ca-certificates curl gnupg lsb-release | sudo tee -a $LOG_FILE
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release; echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update | sudo tee -a $LOG_FILE
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin | sudo tee -a $LOG_FILE

# Configuration de Docker Compose pour CouchDB
echo "Configuration de Docker Compose pour CouchDB..." | sudo tee -a $LOG_FILE
sudo mkdir -p /home/debian/docker | sudo tee -a $LOG_FILE
sudo cp /home/debian/cyberday-cs-custom/docker-compose.yaml /home/debian/docker | sudo tee -a $LOG_FILE
cd /home/debian/docker | sudo tee -a $LOG_FILE
sudo docker compose up -d | sudo tee -a $LOG_FILE

##Configuration users couchdb
echo "Configuration users couchdb..." | sudo tee -a $LOG_FILE
cd /home/debian/cyberday-cs-custom/
sudo chmod +x setupCouch.sh
sudo ./setupCouch.sh | sudo tee -a $LOG_FILE

# Ajouter des paramètres à local.ini
sudo awk '/\[chttpd\]/{f=1} f && /^$/{if(!a++)print "authentication_handlers = {chttpd_auth, proxy_authentication_handler}, {chttpd_auth, default_authentication_handler}";next} 1; END{if(!f){print "[chttpd]\nauthentication_handlers = {chttpd_auth, proxy_authentication_handler}, {chttpd_auth, default_authentication_handler}";}}' /etc/couchdb/config/local.ini


echo "Configuration terminée avec succès!" | sudo tee -a $LOG_FILE
