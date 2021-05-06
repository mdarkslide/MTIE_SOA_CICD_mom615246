#!/bin/bash

echo '=========================================================='
echo '===        MTIE mom615246 MIGUEL OLMOS MARES           ==='
echo '=========================================================='

echo '=========================================================='
echo '=== PASO 1: CONFIGURACION DE VARIABLE VM.MAX_MAP_COUNT ==='
echo '=========================================================='
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -p

echo '=========================================================='
echo '===       PASO 2: INSTALACION DE DOCKER-COMPOSE        ==='
echo '=========================================================='
sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo '=========================================================='
echo '===            PASO 3: CONFIGURANDO GIT                ==='
echo '=========================================================='
alias git="docker run -ti --rm -v $(pwd):/git bwits/docker-git-alpine"

echo '=========================================================='
echo '===         FIN DE LA CONFIGURACION INICIAL            ==='
echo '=========================================================='

echo '=========================================================='
echo '===         PASO 4: LIMPIANDO REPOSITORIO LOCAL        ==='
echo '=========================================================='
if [ -d ~/MTIE_SOA_CICD_mom615246/ ]; then
    echo 'sudo rm -R MTIE_SOA_CICD_mom615246'
    sudo rm -R MTIE_SOA_CICD_mom615246
else
    echo 'No existe el directorio del repositorio MTIE_SOA_CICD_mom615246'
fi

echo '=========================================================='
echo '===      PASO 5: CLONANDO REPOSITORIO DESDE GIT        ==='
echo '=========================================================='
git clone https://github.com/mdarkslide/MTIE_SOA_CICD_mom615246.git
cd MTIE_SOA_CICD_mom615246

echo '=========================================================='
echo '===          PASO 6: LIMPIANDO DATA Y VOLUMES          ==='
echo '=========================================================='
if [ -d ~/volumes/ ]; then
    echo 'sudo rm -R volumes'
    sudo rm -R volumes
else
    echo ''
    echo 'No existe el directorio volumes'
fi

if [ -d ~/data/ ]; then
    echo 'sudo rm -R data'
    sudo rm -R data
else
    echo ''
    echo 'No existe el directorio data'
fi

echo '=========================================================='
echo '===          PASO 7: COPIANDO DATA Y VOLUMES           ==='
echo '=========================================================='
if [ -d ./volumes/ ]; then
    sudo cp -R volumes/ ~/
    sudo mkdir -p ~/volumes/elk-stack/elasticsearch
    cd ~/volumes/elk-stack/
    sudo chmod 777 elasticsearch/
    cd ~/MTIE_SOA_CICD_mom615246
else
    echo 'No existe el directorio volumes'
fi

if [ -d ./data/ ]; then
    echo 'sudo cp -R data/ ~/'
    sudo cp -R data/ ~/
else
    echo 'No existe el directorio data'
fi

echo '=========================================================='
echo '===          PASO 8: DESPLEGANDO CONTENEDORES          ==='
echo '=========================================================='
echo 'sudo docker-compose up --build -d'
sudo docker-compose up --build -d
