#!/bin/bash

# # Configuration de /etc/hosts
# Obtenir le nom d'hôte de la machine
hostname=$(hostname)

# Obtenir l'adresse IP publique
public_ip=$(curl -s http://ipinfo.io/ip)

# Ajouter l'IP publique et le nom d'hôte à /etc/hosts
echo "$public_ip $hostname" | sudo tee -a /etc/hosts

# Configuration des modules pour containerd
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

wget https://github.com/containerd/containerd/releases/download/v1.7.10/containerd-1.7.10-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.10-linux-amd64.tar.gz
sudo wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
wget https://github.com/opencontainers/runc/releases/download/v1.1.10/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
sudo  mkdir -p /opt/cni/bin
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz
# Générer la configuration par défaut de containerd
sudo containerd config default > "$HOME/containerd-config.toml"
sudo mkdir -p /etc/containerd
# Modifier la configuration pour utiliser SystemdCgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' "$HOME/containerd-config.toml"

# Déplacer la configuration modifiée vers le répertoire de configuration de containerd
sudo mv "$HOME/containerd-config.toml" /etc/containerd/config.toml


# Redémarrage et activation de containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

#Configuration de sysctl pour Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
# Append the configuration to disable IPv6 to sysctl.conf
# Disable ipv6 for curl key gpg key 
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

# Reload sysctl configuration to apply changes
sudo sysctl -p
echo "IPv6 disabled successfully."
# Configuration des iptables
# Désactivation du Swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Désactivation du Firewall (ou ajustez selon votre environnement)
sudo ufw disable

# Configuration des iptables
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo apt-get install -y apt-transport-https ca-certificates curl gpg gnupg
sudo mkdir -m 755 /etc/apt/keyrings
# Ajout du dépôt Kubernetes et installation des paquets
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
# Activation du service kubelet
sudo systemctl enable kubelet
# Append the configuration to disable IPv6 to sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 0" | sudo tee -a /etc/sysctl.conf

# Reload sysctl configuration to apply changes
sudo sysctl -p
echo "IPv6 Enabled successfully."
echo 'Finish !!'
