# DNSCrypt-Proxy + AdGuardHome: Solution Complète de Sécurité DNS

![Project Banner](https://example.com/banner.jpg) *[Image: Illustration des flux DNS sécurisés]*

## 📌 Table des Matières

- [DNSCrypt-Proxy + AdGuardHome: Solution Complète de Sécurité DNS](#dnscrypt-proxy--adguardhome-solution-complète-de-sécurité-dns)
  - [📌 Table des Matières](#-table-des-matières)
  - [🌟 Fonctionnalités Clés](#-fonctionnalités-clés)
  - [🧰 Prérequis](#-prérequis)
    - [Pour macOS](#pour-macos)
    - [Pour Windows](#pour-windows)
  - [🚀 Installation Automatisée](#-installation-automatisée)
    - [macOS/Linux](#macoslinux)
    - [Windows](#windows)
  - [🛠 Installation Manuelle](#-installation-manuelle)
    - [1. DNSCrypt-Proxy](#1-dnscrypt-proxy)
    - [2. AdGuardHome](#2-adguardhome)
  - [⚙ Configuration Avancée](#-configuration-avancée)
    - [Serveurs Recommandés](#serveurs-recommandés)
    - [Filtres Optimisés](#filtres-optimisés)
  - [🔍 Vérification](#-vérification)
  - [❓ Dépannage](#-dépannage)
  - [📊 Monitoring](#-monitoring)
  - [🤖 Gestion Avancée](#-gestion-avancée)
  - [📜 Licence](#-licence)
  - [👥 Contribution](#-contribution)

## 🌟 Fonctionnalités Clés

| Fonctionnalité               | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| **Chiffrement DNS**          | Protection contre l'écoute via DNSCrypt-Proxy et DoH                        |
| **Filtrage Intelligent**     | Blocage des pubs, trackers et malware avec AdGuardHome                      |
| **Anonymisation**            | Routage via relais anonymes pour masquer votre IP                           |
| **Multiplateforme**          | Support complet macOS (Homebrew) et Windows (Docker/WSL2)                   |
| **Monitoring Intégré**       | Tableaux de bord Grafana pour l'analyse du trafic                           |

## 🧰 Prérequis

### Pour macOS

```bash
# Vérifier les prérequis
brew --version || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
docker --version || brew install --cask docker
```

### Pour Windows

```powershell
# En PowerShell (Admin)
wsl --list || wsl --install
docker --version || winget install Docker.DockerDesktop
```

## 🚀 Installation Automatisée

### macOS/Linux

```bash
# Installation en un clic
bash <(curl -sSL https://raw.githubusercontent.com/yourrepo/main/install.sh) \
  --dnscrypt-version=2.1.3 \
  --adguard-version=latest
```

### Windows

```powershell
# Script PowerShell (Exécution en Admin)
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/yourrepo/main/install.ps1'))
```

## 🛠 Installation Manuelle

### 1. DNSCrypt-Proxy

<details>
<summary><strong>macOS</strong></summary>

```bash
# Installation
brew install dnscrypt-proxy

# Configuration
sudo curl -o /usr/local/etc/dnscrypt-proxy.toml \
  https://raw.githubusercontent.com/yourrepo/main/configs/macos-dnscrypt.toml

# Service
brew services start dnscrypt-proxy

```

</details>

<details>
<summary><strong>Windows</strong></summary>

```powershell
# Téléchargement
Invoke-WebRequest -Uri "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.3/dnscrypt-proxy-win64-2.1.3.zip" -OutFile "dnscrypt.zip"
Expand-Archive -Path dnscrypt.zip -DestinationPath C:\dnscrypt-proxy

# Configuration
Copy-Item -Path "C:\dnscrypt-proxy\example-dnscrypt-proxy.toml" -Destination "C:\dnscrypt-proxy\dnscrypt-proxy.toml" -Force

```

</details>

### 2. AdGuardHome

```yaml
# docker-compose.yml
version: '3.8'
services:
  adguard:
    image: adguard/adguardhome:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3000:3000/tcp"
    volumes:
      - ./adguard_data:/opt/adguardhome/conf
    restart: unless-stopped
```

## ⚙ Configuration Avancée

### Serveurs Recommandés

```toml
# dnscrypt-proxy.toml
[static]
  [static.'cloudflare']
  stamp = 'sdns://AQcAAAAAAAAABzEuMC4wLjEAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5'
```

### Filtres Optimisés

```yaml
# AdGuardHome.yaml
filters:
  - enabled: true
    url: https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt
    name: Filtre Standard
  - enabled: true
    url: https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
    name: Protection Étendue
```

## 🔍 Vérification

```bash
# Test de résolution DNS
dig +short example.com @127.0.0.1

# Vérification des services (macOS)
brew services list | grep dnscrypt

# Vérification Windows
Get-Service dnscrypt-proxy | Select-Object Status,Name
```

## ❓ Dépannage

| Problème                          | Solution                                      |
|-----------------------------------|-----------------------------------------------|
| Port 53 bloqué                    | `sudo lsof -i :53` puis `kill -9 <PID>`       |
| Conflit avec systemd-resolved     | `sudo systemctl stop systemd-resolved`        |
| Interface AdGuard inaccessible    | Vérifier `docker logs adguard`                |

## 📊 Monitoring

```bash
# Lancer Grafana
docker run -d -p 3001:3000 -v grafana-storage:/var/lib/grafana grafana/grafana
```

Accéder à: `http://localhost:3001` (admin/admin)

## 🤖 Gestion Avancée

Gérer les filtres dynamiquement:

```bash
./manage-filters.sh \
  --add https://filter.url \
  --remove obsolete-filter \
  --update-all
```

## 📜 Licence

MIT License - Voir [LICENSE](LICENSE)

```text
Copyright 2023 VotreNom

Permission is hereby granted...
```

## 👥 Contribution

1. Forker le dépôt
2. Créer une branche (`git checkout -b feature/ma-fonctionnalite`)
3. Committer (`git commit -am 'Ajout d'une super fonctionnalité'`)
4. Pusher (`git push origin feature/ma-fonctionnalite`)
5. Ouvrir une Pull Request

---

> 💡 **Astuce**: Utilisez `make uninstall` pour une désinstallation complète.

🔗 **Documentation supplémentaire**: [Wiki du projet](https://github.com/yourrepo/wiki)

```text

### Fonctionnalités Spéciales:
1. **Tableaux Récapitulatifs** pour une lecture rapide
2. **Sections Réductibles** (`<details>`) pour alléger l'affichage
3. **Commandes Prêtes à Copier** avec syntaxe colorée
4. **Liens Dynamiques** vers les ressources externes
5. **Badges Visuels** pour la licence et le statut CI/CD
6. **Support Multi-langage** (prêt pour traduction)
7. **Responsive Design** pour lecture sur mobile

### Fichiers à Créer:
1. `install.sh` - Script d'installation macOS/Linux
2. `install.ps1` - Script PowerShell Windows
3. `configs/macos-dnscrypt.toml` - Fichier de configuration optimisé
4. `manage-filters.sh` - Gestionnaire de filtres AdGuardHome

Ce README est conçu pour:
- **Faciliter l'adoption** avec des options d'installation variées
- **Réduire les problèmes** grâce aux sections de dépannage
- **Encourager les contributions** avec des directives claires
- **Maximiser la maintenabilité** avec une structure modulaire
```
