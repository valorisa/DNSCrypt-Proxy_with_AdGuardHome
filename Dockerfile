# Utiliser une image de base pour DNSCrypt-Proxy
FROM alpine:latest AS dnscrypt-proxy

# Installer les dépendances et DNSCrypt-Proxy
RUN apk update && apk add --no-cache dnscrypt-proxy

# Copier le fichier de configuration
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# Exposer le port DNS
EXPOSE 53/udp

# Démarrer DNSCrypt-Proxy
CMD ["dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]

# Utiliser une image de base pour AdGuardHome
FROM adguard/adguardhome:latest AS adguard

# Copier le fichier de configuration AdGuardHome
COPY AdGuardHome.yaml /opt/adguardhome/AdGuardHome.yaml

# Exposer les ports nécessaires
EXPOSE 53/tcp 53/udp 3000/tcp

# Démarrer AdGuardHome
CMD ["./AdGuardHome/AdGuardHome", "-c", "/opt/adguardhome/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]

# Combiner les deux services dans une image finale
FROM alpine:latest

# Copier les services des images précédentes
COPY --from=dnscrypt-proxy /usr/sbin/dnscrypt-proxy /usr/sbin/dnscrypt-proxy
COPY --from=adguard /opt/adguardhome /opt/adguardhome

# Exposer les ports nécessaires
EXPOSE 53/tcp 53/udp 3000/tcp

# Démarrer les deux services
CMD ["/usr/sbin/dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml", "&&", "/opt/adguardhome/AdGuardHome", "-c", "/opt/adguardhome/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]