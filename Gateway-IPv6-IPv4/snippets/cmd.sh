# Installation du docker-engine
yum install docker-engine
systemctl enable docker.service
systemctl start docker


# Installation & Démarrage de Traefik
# Le fichier de configuration doit être dans le répertoire courant
docker pull traefik
docker run -d -p 443:443 -p 80:80 -v $PWD/traefik.toml:/etc/traefik/traefik.toml traefik
