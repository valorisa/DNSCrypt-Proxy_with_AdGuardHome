```markdown
# DNSCrypt-Proxy_with_AdGuardHome

Ce projet configure DNSCrypt-Proxy en tandem avec AdGuardHome sur Windows 11 Enterprise pour sécuriser et filtrer les requêtes DNS.

## Prérequis

- Windows 11 Enterprise
- [Cygwin](https://www.cygwin.com/)
- [Git Bash](https://gitforwindows.org/)
- [Docker Desktop](https://docs.docker.com/desktop/windows/install/)

## Installation

### Étape 1 : Installation de DNSCrypt-Proxy

1. **Télécharger DNSCrypt-Proxy** :
   - Téléchargez la dernière version de DNSCrypt-Proxy pour Windows depuis [la page des releases sur GitHub](https://github.com/DNSCrypt/dnscrypt-proxy/releases).

2. **Extraire DNSCrypt-Proxy** :
   - Extrayez les fichiers téléchargés dans un répertoire, par exemple `C:\dnscrypt-proxy`.

3. **Configurer DNSCrypt-Proxy** :
   Modifiez le fichier de configuration `dnscrypt-proxy.toml` pour écouter sur l'adresse locale `127.0.0.1:5353`. Vous pouvez utiliser un éditeur de texte comme Notepad++ ou Visual Studio Code :

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
   log_file = 'C:/dnscrypt-proxy/dnscrypt-proxy.log'
   ```

4. **Ajouter DNSCrypt-Proxy au démarrage** :
   - Créez un raccourci du fichier `dnscrypt-proxy.exe` et placez-le dans le dossier de démarrage de Windows (`C:\Users\<VotreNom>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`).

5. **Démarrer DNSCrypt-Proxy** :
   - Ouvrez Git Bash ou Cygwin et exécutez la commande suivante pour démarrer DNSCrypt-Proxy :

   ```bash
   cd /cygdrive/c/dnscrypt-proxy
   ./dnscrypt-proxy.exe
   ```

### Étape 2 : Installation et Configuration d'AdGuardHome

1. **Installer Docker Desktop** :
   - Suivez les instructions sur [docs.docker.com](https://docs.docker.com/desktop/windows/install/) pour installer Docker Desktop sur Windows.

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
   - Ouvrez Git Bash ou Cygwin et exécutez la commande suivante :

   ```bash
   docker-compose up -d
   ```

### Étape 3 : Configuration des Paramètres DNS sur Windows

1. **Configurer les Paramètres DNS de Windows** :
   - Ouvrez les "Paramètres réseau et Internet".
   - Cliquez sur "Modifier les options d'adaptateur".
   - Faites un clic droit sur votre connexion réseau (Wi-Fi ou Ethernet) et sélectionnez "Propriétés".
   - Sélectionnez "Protocole Internet version 4 (TCP/IPv4)" et cliquez sur "Propriétés".
   - Cochez "Utiliser l'adresse de serveur DNS suivante" et entrez `127.0.0.1` comme serveur DNS préféré.
   - Vous pouvez conserver `192.168.1.254` comme serveur DNS secondaire pour le basculement.

## Vérification de la Configuration

1. **Vérifier que les services sont en cours d'exécution** :
   - Dans Git Bash ou Cygwin, exécutez :

   ```bash
   docker ps
   ```

2. **Tester la Résolution DNS** :
   Utilisez la commande `nslookup` pour tester une requête DNS :

   ```bash
   nslookup example.com 127.0.0.1
   ```

3. **Surveillance des Logs** :
   Utilisez Git Bash ou Cygwin pour surveiller les logs de DNSCrypt-Proxy :

   ```bash
   tail -f /cygdrive/c/dnscrypt-proxy/dnscrypt-proxy.log
   ```

## Conclusion

En suivant ces étapes, vous aurez configuré DNSCrypt-Proxy et AdGuardHome sur Windows 11 Enterprise pour sécuriser et filtrer vos requêtes DNS. Si vous avez des questions ou rencontrez des problèmes, n'hésitez pas à demander de l'aide.
```
