# Configura tu entorno para desarrollo

## Autenticación mediante SSH

1. En tu cliente liviano crea tu clave SSH con: `ssh-keygen`
1. Agrega tu clave SSH al agente para hacer _forwarding_: `ssh-add ~/.ssh/id_rsa`
1. Agrega la clave SSH pública[^ssh_pub] de tu cliente liviano a:
    - [Bitbucket](https://bitbucket.org/account/settings/ssh-keys/),
    - [DigitalOcean](https://cloud.digitalocean.com/account/security) y
    - [GitHub](https://github.com/settings/keys/)

[^ssh_pub]: Copia el contenido del archivo `~/.ssh/id_rsa.pub` de tu cliente liviano y pégalo en las aplicaciones indicadas

## En tu cliente liviano

- [ ] TODO: Mover esta sección a [`src/start_containers.sh`](https://github.com/IslasGECI/islasgeci.org/blob/develop/src/start_containers) de [islasgeci.org](https://github.com/IslasGECI/islasgeci.org) o al servidor donde corre el Inspector. (Las instrucciones de esta sección dependen de Docker por lo que no pueden correr en los clientes livianos.)

> Abajo reemplaza `<Token de DigitalOcean>` con tu token de accesso personal de DigitalOcean
    
Para crear el servidor de desarrollo debemos ejecutar lo siguiente:
```shell
sudo apt update && sudo apt install --yes docker.io
docker pull islasgeci/development_server_setup:latest
export DO_PAT=<Token de DigitalOcean>
docker-compose run islasgeci
```
Cada mañana para conectarte al servidor desde tu cliente liviano deberás de hacer lo siguiente:
```shel
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "islasgeci.dev"
ssh-keyscan "islasgeci.dev" >> "$HOME/.ssh/known_hosts"
export DEVELOPER=<Tu nombre de usuario del servidor>
scp -pr ~/.vault $DEVELOPER@islasgeci.dev:/home/$DEVELOPER/.vault
ssh -o ForwardAgent=yes $DEVELOPER@islasgeci.dev
```

## Usuarios

Para configurar tu usuario del servidor necesitas agregar tu repositorio `dotfiles`. Estas son las
características del repositorio:
1. Que el repositorio se llame `dotfiles`
1. Que en la rama _develop_ tenga un `Makefile`
1. Que el `Makefile` tenga al menos un _target_

Actualmente usamos [la configuración por defecto del analislas](https://github.com/analislas/dotfiles).
