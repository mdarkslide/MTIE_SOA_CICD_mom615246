#!/bin/bash

echo '=========================================================='
echo '===        MTIE mom615246 MIGUEL OLMOS MARES           ==='
echo '                                                          '
echo '                                                          '
echo '                             ##          ·                '
echo '                       ## ## ##         ==                '
echo '                    ## ## ## ## ##     ===                '
echo '                 /""""""""""""""""\____/ ===              '
echo '            ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~       '
echo '                 \______             __/                  '
echo '                   \    \         __/                     '
echo '                    \____\_______/                        '
echo '                                                          '
echo '                                                          '
echo '                     |          |                         '
echo '                  __ |  __   __ | _  __   _               '
echo '                 /  \| /  \ /   |/  / _\ |                '
echo '                 \__/| \__/ \__ |\_ \__  |                '
echo '                                                          '
echo '                                                          '
echo '===         INICIA LA EJECUCION DEL UPDATE.SH          ==='
echo '=========================================================='

echo '=========================================================='
echo '===            PASO 1: CONFIGURANDO GIT                ==='
echo '=========================================================='
alias git="docker run -ti --rm -v $(pwd):/git bwits/docker-git-alpine"

echo '=========================================================='
echo '===         FIN DE LA CONFIGURACION INICIAL            ==='
echo '=========================================================='

echo '=========================================================='
echo '===         PASO 2: LIMPIANDO REPOSITORIO LOCAL        ==='
echo '=========================================================='
if [ -d ~/MTIE_SOA_CICD_mom615246/ ]; then
    echo 'sudo rm -R MTIE_SOA_CICD_mom615246'
    sudo rm -R MTIE_SOA_CICD_mom615246
else
    echo 'No existe el directorio del repositorio MTIE_SOA_CICD_mom615246'
fi

echo '=========================================================='
echo '===      PASO 3: CLONANDO REPOSITORIO DESDE GIT        ==='
echo '=========================================================='
git clone https://github.com/mdarkslide/MTIE_SOA_CICD_mom615246.git
cd MTIE_SOA_CICD_mom615246

echo '=========================================================='
echo '===        PASO 4: ACTUALIZANDO DATA Y VOLUMES         ==='
echo '=========================================================='
if [ -d ./volumes/ ]; then
    sudo cp -U volumes/ ~/
    sudo mkdir -p ~/volumes/elk-stack/elasticsearch
    cd ~/volumes/elk-stack/
    sudo chmod 777 elasticsearch/
    cd ~/MTIE_SOA_CICD_mom615246
else
    echo 'No existe el directorio volumes'
fi

if [ -d ./data/ ]; then
    echo 'sudo cp -R data/ ~/'
    sudo cp -U data/ ~/
else
    echo 'No existe el directorio data'
fi

echo '=========================================================='
echo '===          PASO 5: DESPLEGANDO CONTENEDORES          ==='
echo '=========================================================='
echo 'sudo docker-compose up --build -d'
sudo docker-compose up --build -d
