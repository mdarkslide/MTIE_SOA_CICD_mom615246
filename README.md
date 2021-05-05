# MTIE_SOA_CICD_mom615246
## Maestría en Tecnologías de Información Empresarial
## 143 - 02MTI513 - Modelos de Arquitecturas Orientadas a los Servicios

(/DeLa Salle_FTI_Color.png "Logo de la Facultad de Tecnologías de la Información.")

### Presenta: 615246 - Miguel Olmos Mares 
### Proyecto Final

> Proyecto final para la creación de una máquina virtual con RancherOS en la cual se crearan los contenedores necesarios para crear un dashboard con Logstash, Elasticsearch y Kibana a partir de la información de una base de datos en MySQL.

## Creación de una maquina virtual con docker-machine
### Instalación de Docker Machine en Windows

1. Verificar que ese deshabilitado el soporte para **Hyper-V** desde *Activar o desactivar las características de Windows* en Panel de Control. 
   - Para algunos casos verificar que esten deshabilitadas las opciones *Virtual Machine Platform* y *Windows Hypervisor Platform*.
2. Descargar e instalar [VirtualBox](https://www.virtualbox.org/wiki/Downloads). 
3. Ejecutar **PowerShell** con privilegios de adminstrador: 
``` 
bcdedit /set hypervisorlaunchtype off 
```
4. Instalar [Docker Desktop](https://www.docker.com/products/docker-desktop) para todos los usuarios y reiniciar.
5. Ejecutar **PowerShell** con privilegios de adminstrador e instalar **Chocolatey**: 
``` 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
``` 
6. Confirmar la versión instalada de Chocolatey. 
``` 
choco --version
``` 
7. Se utiliza **PowerShell** para instalar **docker-machine** a través de **Chocolatey**: 
``` 
choco install docker-machine 
``` 

8. Confirmar la versión instalada de **docker-machine**: 
``` 
docker-machine --version 
``` 
### Crear una maquina virtual con RancherOS utilizando docker-machine

Crear una maquina con docker-machine utilizando el driver de virtualbox con 2 CPUs, 20GB de almacenamiento y 5GB de RAM denominada **elk-stack**, el resto de los parametros del driver se pueden consultar en [docker docs](http://docs.docker.oeynet.com/machine/drivers/virtualbox/#options). 
 
_--virtualbox-cpu-count: Número de CPU que se utilizarán para crear la máquina virtual. Default 1 CPU._ 
 
_--virtualbox-disk-size: Tamaño del disco asignado a la máquina virtual en MB._ 
 
_--virtualbox-memory: Tamaño de la memoria RAM asignada a la máquina virtual en MB._ 
 
_--virtualbox-boot2docker-url: URL de la imagen de boot2docker (Última versión disponible)._ 
>
 
 ``` 
docker-machine create --driver virtualbox --virtualbox-cpu-count 2 --virtualbox-disk-size 20000 --virtualbox-memory 5120 --virtualbox-boot2docker-url https://releases.rancher.com/os/latest/rancheros.iso elk-stack
``` 
 
### Lista de comandos para docker-machine
Comando | Descripción
------------ | -------------
docker-machine ls | Ver la lista de VMs creadas
docker-machine start *nombre_VM* | Iniciar una VM
docker-machine stop *nombre_VM* | Detener una VM
docker-machine rm -y *nombre_VM* | Eliminar una VM sin confirmación
docker-machine ssh *nombre_VM* | Conectarse a una VM a traves de SSH

### Configuración de la máquina virtual para la creación de los contenedores 
1. Conectarse a la máquina virtual creada en el paso anterior. 
``` 
docker-machine ssh *nombre_VM* 
``` 
2. Habilitar la consola de Ubuntu en RancherOS:
``` 
sudo ros console switch ubuntu 
``` 
3. Instalar docker-compose en RancherOS
``` 
sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
``` 
4. Cambiar los permisos a la carpeta generada en la instalación de git:
```
sudo chmod +x /usr/local/bin/docker-compose
```
5. Crear un alias para ejecutar Git sin instalarlo. 
``` 
alias git="docker run -ti --rm -v $(pwd):/git bwits/docker-git-alpine" 
``` 
6. Configurar variable **vm.max_map_count** dentro del archivo de configuración **sysctl**. 
``` 
sudo vi /etc/sysctl.conf 
``` 
7. En el editor **vi** presionar ESC + i (insert) y agregar al final del archivo la siguiente linea sin comentar: 
**vm.max_map_count=2621444**.
> Para guardar los cambios presionar [ESC] y después escribir `:wq` (*write y *quit).

8. Verificar el valor de la variable sysctl, ejecutar:
``` 
sudo sysctl -p 
``` 
9. Verificar la IP asignada a la máquina virtual
``` 
ifconfig 
``` 
10. En el archivo host (%windir%\System32\drivers\etc\host) y agregar la IP asignada para la URL de Kibana
``` 
XX.XX.XX.XX	kibana.midominiomtie.net
``` 
### Descarga del proyecto desde el repositorio de git
Se ejecutara un script que realizará las siguientes acciones:
1. Clonar el repositorio de este proyecto en la máquina virtual
2. Crear una carpeta para elasticsearch dentro de la carpeta del proyecto y darle los permisos necesarios.
3. Moverá los archivos a la raiz desde la carpeta donde se encuentra el proyecto **MTIE_SOA_CICD_mom615246** en el que se encuentra el archivo YAML **\*docker-compose\*** que contiene todas las instrucciones para la creación de los contenedores. 
``` 
git clone https://github.com/mdarkslide/MTIE_SOA_CICD_mom615246.git && \
cd MTIE_SOA_CICD_mom615246 && \
sudo cp -R volumes/ ~/ && \
sudo mkdir -p ~/volumes/elk-stack/elasticsearch && \
cd ~/volumes/elk-stack/ && \
sudo chmod 777 elasticsearch/ && \
cd ~/MTIE_SOA_CICD_mom615246 && \
sudo cp -R data/ ~/ && \
sudo docker-compose up --build -d
``` 
> En caso de requerir eliminar la carpeta del proyecto para descargar una nueva versión desde el repositorio ejecutar:
``` 
sudo rm -r *nombre carpeta*
``` 
### Lista de comandos para contenedores
Comando | Descripción
------------ | -------------
docker ps -a | Ver la lista de todos los contenedores creados
docker exec -it *nombre_contenedor* bash | Entrar a un contenedor
docker logs --follow --tail 10 *nombre_contenedor* | Ver el log del contenedor (10 líneas)
docker rm -fv *nombre_contenedor* | Eliminar un contenedor
docker rm -f $(docker ps -qa) | Eliminar todos los contenedores
docker images | Ver la lista de las imagenes en el repositorio de docker
docker rmi -f $(docker images -a -q) | Eliminar todas las imagenes del repositorio
### Consulta del dashboard
El tablero generado en Kibana se puede consultar en un navegador:
``` 
http://kibana.midominiomtie.net/
``` 
## Recursos
> Los detalles de este proyecto se describen en el siguiente articulo: [How to synchronize Elasticsearch with MySQL](https://towardsdatascience.com/how-to-synchronize-elasticsearch-with-mysql-ed32fc57b339)
- Inspiration by [How to keep Elasticsearch synchronized with a relational database using Logstash and JDBC](https://www.elastic.co/blog/how-to-keep-elasticsearch-synchronized-with-a-relational-database-using-logstash). However the article does not deal with indexing from scratch and deleted records.
- Data used for this project is available in the Kaggle dataset [Goodreads-books](https://www.kaggle.com/jealousleopard/goodreadsbooks)
- [Logstash JDBC input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-jdbc.html)
- [Logstash Mutate filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html)
- [Logstash Elasticsearch output plugin](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html)
### ¡Gracias!
## Fin