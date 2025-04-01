# DNSCrypt-Proxy avec AdGuard Home via Docker Compose

Ce projet configure [DNSCrypt-Proxy](https://github.com/DNSCrypt/dnscrypt-proxy) et [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) pour fonctionner ensemble en utilisant Docker Compose sur macOS (ou Linux/Windows avec Docker). AdGuard Home agit comme serveur DNS principal, filtrant les publicités et les traqueurs, et utilise DNSCrypt-Proxy comme unique serveur amont (upstream) pour chiffrer et anonymiser les requêtes DNS sortantes.

## Architecture

Vos Appareils --> AdGuard Home (Docker) --> DNSCrypt-Proxy (Docker) --> Résolveurs DNS Chiffrés
| | |
(DNS: 127.0.0.1) (Port 53) (Port interne 5353)
|
(Filtrage + Cache)


## Prérequis

-   [Docker Engine](https://docs.docker.com/engine/install/)
-   [Docker Compose](https://docs.docker.com/compose/install/) (Souvent inclus avec Docker Desktop sur macOS et Windows)

## Mise en Place

1.  **Cloner le dépôt ou créer les fichiers :**
    Si vous avez cloné ce dépôt, les fichiers nécessaires sont déjà présents. Sinon, créez les fichiers suivants dans un nouveau dossier (par exemple `mon-dns`) :
    *   `docker-compose.yml` (voir contenu ci-dessous)
    *   `dnscrypt-proxy.toml` (fichier de configuration pour DNSCrypt-Proxy)

2.  **Créer les répertoires pour les volumes AdGuard :**
    Dans le même dossier, créez les répertoires qui stockeront les données persistantes d'AdGuard Home :
    ```bash
    mkdir adguard_work adguard_conf
    ```

3.  **Contenu du fichier `docker-compose.yml` :**
    ```yaml
    version: '3.8'

    services:
      dnscrypt-proxy:
        image: klutchell/dnscrypt-proxy:latest # Ou une autre image de votre choix
        container_name: dnscrypt
        restart: unless-stopped
        volumes:
          # Assurez-vous que ce chemin correspond à l'emplacement de votre fichier .toml
          - ./dnscrypt-proxy.toml:/config/dnscrypt-proxy.toml:ro
        networks:
          - dns-network
        # Pas de ports exposés sur l'hôte, AdGuard y accède via le réseau interne

      adguardhome:
        image: adguard/adguardhome:latest
        container_name: adguard
        restart: unless-stopped
        ports:
          # Port DNS standard exposé sur l'hôte
          - "53:53/tcp"
          - "53:53/udp"
          # Port pour l'interface web d'AdGuard (http://127.0.0.1:3000)
          - "3000:3000/tcp"
          # Décommentez/ajoutez d'autres ports si besoin (DoT: 853, DoH: 443, etc.)
          # - "853:853/tcp"
          # - "443:443/tcp"
        volumes:
          - ./adguard_work:/opt/adguardhome/work
          - ./adguard_conf:/opt/adguardhome/conf
        depends_on:
          - dnscrypt-proxy # S'assure que dnscrypt démarre avant adguard
        networks:
          - dns-network

    networks:
      dns-network:
        driver: bridge

    # Décommentez si vous préférez gérer les volumes explicitement
    # volumes:
    #   adguard_work:
    #   adguard_conf:
    ```

## Configuration

### 1. Fichier `dnscrypt-proxy.toml`

C'est le fichier de configuration principal pour DNSCrypt-Proxy. Vous devez le créer ou le modifier. **Le paramètre le plus important est `listen_addresses`**.

-   **Placez** ce fichier `dnscrypt-proxy.toml` dans le même dossier que `docker-compose.yml`.
-   **Modifiez** le fichier pour qu'il écoute sur `0.0.0.0` sur un port non standard (qui ne sera PAS exposé à l'extérieur de Docker). **N'utilisez PAS `127.0.0.1` ici**, car AdGuard doit pouvoir y accéder depuis son propre conteneur via le réseau Docker.

    Exemple de configuration minimale pour `dnscrypt-proxy.toml` :

    ```toml
    # Écoute sur toutes les interfaces internes du conteneur, sur le port 5353
    # AdGuard contactera dnscrypt-proxy sur ce port via le réseau Docker.
    listen_addresses = ['0.0.0.0:5353']

    # Choisissez vos serveurs DNS préférés (exemples)
    server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

    # Désactiver IPv6 si non nécessaire/supporté
    ipv6_servers = false

    # Options recommandées (adaptez selon vos besoins)
    require_dnssec = true
    require_no_log = true
    require_nofilter = true # Le filtrage sera fait par AdGuard

    # Chemin du cache (interne au conteneur, facultatif)
    # cache = true
    # cache_size = 4096
    # cache_neg_ttl = 60
    # cache_min_ttl = 600

    # Pas besoin de log_file généralement, utilisez 'docker-compose logs'
    ```

    *Adaptez `server_names` et les autres options selon vos préférences.*

### 2. Configuration Initiale d'AdGuard Home (Après Lancement)

La configuration principale d'AdGuard Home se fait via son interface web après le premier démarrage.

## Démarrage des Services

1.  Ouvrez un terminal dans le dossier contenant vos fichiers `docker-compose.yml` et `dnscrypt-proxy.toml`.
2.  Lancez les conteneurs en arrière-plan :
    ```bash
    docker-compose up -d
    ```

## Configuration Post-Lancement d'AdGuard Home

1.  **Accéder à l'interface web :** Ouvrez votre navigateur et allez sur `http://127.0.0.1:3000` (ou `http://<ip-de-votre-machine>:3000` si vous y accédez depuis une autre machine).
2.  **Assistant de configuration :** Suivez les étapes de l'assistant initial d'AdGuard Home.
    *   Configurez les interfaces d'écoute (normalement, laissez par défaut pour écouter sur le port 3000 pour le web et 53 pour le DNS).
    *   Créez un nom d'utilisateur et un mot de passe administrateur.
3.  **Configurer le Serveur DNS Amont (Upstream) - ÉTAPE CRUCIALE :**
    *   Une fois connecté à l'interface AdGuard, allez dans **Paramètres** -> **Paramètres DNS**.
    *   Dans la section **Serveurs DNS en amont**, **supprimez toutes les entrées par défaut**.
    *   **Ajoutez** l'adresse suivante, en remplaçant `5353` par le port que vous avez défini dans `dnscrypt-proxy.toml` si vous en avez choisi un autre :
        ```
        dnscrypt-proxy:5353
        ```
        *(Docker Compose permet au conteneur `adguardhome` de résoudre le nom de service `dnscrypt-proxy` en son adresse IP interne sur le réseau `dns-network`)*
    *   Vous pouvez éventuellement ajouter un serveur DNS de secours *externe* dans la section **Serveurs DNS de démarrage** (Bootstrap DNS servers), par exemple `1.1.1.1` ou `8.8.8.8`. Ceci est utilisé par AdGuard uniquement pour trouver l'adresse IP des serveurs DoH/DoT/DoQ si vous en configurez, et pour vérifier la connectivité au démarrage. Il n'est **pas** utilisé pour les requêtes DNS normales des clients.
    *   Cliquez sur **Tester les serveurs en amont** pour vérifier la connexion entre AdGuard et DNSCrypt-Proxy.
    *   Cliquez sur **Appliquer**.

## Configuration des Paramètres DNS sur vos Appareils (ex: macOS)

1.  Ouvrez "Réglages Système" (ou "Préférences Système").
2.  Allez dans "Réseau".
3.  Sélectionnez votre connexion active (Wi-Fi ou Ethernet) et cliquez sur "Détails..." (ou "Avancé...").
4.  Allez dans l'onglet "DNS".
5.  Cliquez sur le bouton `+` et ajoutez `127.0.0.1` comme **unique** serveur DNS.
    *   **Important :** Supprimez les autres serveurs DNS (y compris ceux de votre FAI ou routeur, et l'ancien `192.168.1.254`) si vous voulez forcer tout le trafic DNS à passer par votre configuration AdGuard+DNSCrypt. Laissez uniquement `127.0.0.1`.
6.  Cliquez sur "OK" puis "Appliquer".

*(Répétez une opération similaire sur vos autres appareils, en utilisant l'adresse IP de la machine hébergeant Docker comme serveur DNS).*

## Vérification

1.  **Vérifier que les conteneurs sont en cours d'exécution** :
    ```bash
    docker ps
    ```
    *(Vous devriez voir les conteneurs `adguard` et `dnscrypt`)*

2.  **Tester la Résolution DNS** :
    Utilisez `dig` (installez-le via `brew install bind` si nécessaire) ou `nslookup` depuis votre Mac :
    ```bash
    dig example.com @127.0.0.1
    nslookup example.com 127.0.0.1
    ```
    *(La requête doit passer par AdGuard -> DNSCrypt)*

3.  **Consulter les Logs** :
    Pour voir les logs des deux services :
    ```bash
    docker-compose logs -f
    ```
    Pour voir les logs d'un service spécifique (arrêtez avec Ctrl+C) :
    ```bash
    docker-compose logs dnscrypt-proxy
    docker-compose logs adguardhome
    ```
    Consultez également le "Journal des Requêtes" dans l'interface web d'AdGuard Home.

## Mise à Jour

Pour mettre à jour les images AdGuard Home et DNSCrypt-Proxy vers leurs dernières versions (`:latest` ou la version spécifiée dans `docker-compose.yml`) :

1.  Télécharger les nouvelles images :
    ```bash
    docker-compose pull
    ```
2.  Recréer et redémarrer les conteneurs avec les nouvelles images :
    ```bash
    docker-compose up -d
    ```
    *(Votre configuration dans les volumes sera préservée)*

## Arrêt des Services

Pour arrêter et supprimer les conteneurs (sans supprimer les volumes de données) :

```bash
docker-compose down
```

## Conclusion
Vous disposez maintenant d'une configuration DNS locale robuste et sécurisée utilisant AdGuard Home pour le filtrage et DNSCrypt-Proxy pour le chiffrement, le tout géré via Docker Compose. N'hésitez pas à explorer les nombreuses options de configuration d'AdGuard Home (listes de blocage, règles personnalisées, etc.) via son interface web.
