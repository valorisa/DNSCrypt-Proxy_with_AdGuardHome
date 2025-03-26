```markdown
# DNSCrypt-Proxy_with_AdGuardHome

Ce projet configure DNSCrypt-Proxy en tandem avec AdGuardHome sur macOS pour sécuriser et filtrer les requêtes DNS. 

## Prérequis

- macOS
- [Homebrew](https://brew.sh/)
- [Docker](https://docs.docker.com/get-docker/)

## Installation

### Étape 1 : Installation de DNSCrypt-Proxy

1. **Installer Homebrew**, si ce n'est pas déjà fait :
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Installer DNSCrypt-Proxy** :
   ```bash
   brew install dnscrypt-proxy
   ```

3. **Configurer DNSCrypt-Proxy** :
   Modifiez le fichier de configuration `dnscrypt-proxy.toml` pour écouter sur l'adresse locale `127.0.0.1:5353` :
   ```toml
   listen_addresses = ['127.0.0.1:5353']
   max_clients = 250
   ipv4_servers = true
   ipv6_servers = false
   dnscrypt_servers = true
   doh_servers = true
   require_dnssec = true
   require_no_log = true
   require_nofilter = true
   log_file = '/usr/local/var/log/dnscrypt-proxy.log'
   ```

4. **Démarrer DNSCrypt-Proxy** :
   ```bash
   brew services start dnscrypt-proxy
   ```

### Étape 2 : Installation et Configuration d'AdGuardHome

1. **Installer Docker**, si ce n'est pas déjà fait :
   - Suivez les instructions sur [docs.docker.com](https://docs.docker.com/get-docker/) pour installer Docker Desktop sur macOS.

2. **Créer un fichier de configuration pour AdGuardHome** :
   Créez un fichier `AdGuardHome.yaml` avec la configuration suivante :
   ```yaml
   bind_host: 0.0.0.0
   bind_port: 53
   upstream_dns:
     - 127.0.0.1:5353
   ```

3. **Lancer AdGuardHome avec Docker** :
   Créez un fichier `docker-compose.yml` avec le contenu suivant :
   ```yaml
   version: '3'

   services:
     adguardhome:
       image: adguard/adguardhome:latest
       container_name: adguardhome
       volumes:
         - ./AdGuardHome.yaml:/AdGuardHome/AdGuardHome.yaml
       ports:
         - "53:53/tcp"
         - "53:53/udp"
         - "80:80/tcp"
         - "443:443/tcp"
         - "3000:3000/tcp"
       restart: unless-stopped
   ```

4. **Démarrer le conteneur AdGuardHome** :
   ```bash
   docker-compose up -d
   ```

### Étape 3 : Configuration des Paramètres DNS sur macOS

1. **Configurer les Paramètres DNS de macOS** :
   - Ouvrez "Préférences Système".
   - Allez dans "Réseau".
   - Sélectionnez votre connexion active (Wi-Fi ou Ethernet) et cliquez sur "Avancé".
   - Allez dans l'onglet "DNS".
   - Ajoutez `127.0.0.1` comme serveur DNS principal.
   - Vous pouvez conserver `192.168.1.254` comme serveur DNS secondaire pour le basculement.

## Vérification de la Configuration

1. **Vérifier que les services sont en cours d'exécution** :
   ```bash
   brew services list
   docker ps
   ```

2. **Tester la Résolution DNS** :
   Utilisez la commande `dig` pour tester une requête DNS :
   ```bash
   dig example.com @127.0.0.1
   ```

3. **Surveillance des Logs** :
   ```bash
   tail -f /usr/local/var/log/dnscrypt-proxy.log
   ```

## Conclusion

En suivant ces étapes, vous aurez configuré DNSCrypt-Proxy et AdGuardHome sur macOS pour sécuriser et filtrer vos requêtes DNS. Si vous avez des questions ou rencontrez des problèmes, n'hésitez pas à demander de l'aide.

---

```
