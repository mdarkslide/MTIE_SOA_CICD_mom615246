# Proyecto Final
## MTIE_SOA_CICD_mom615246
## Maestría en Tecnologías de Información Empresarial
## 143 - 02MTI513 - Modelos de Arquitecturas Orientadas a los Servicios
## Profesor: Ing. José Luis Rosas Peimbert
### Presenta: 615246 - Miguel Olmos Mares 
![Logo de la Facultad de Tec](http://bajio.delasalle.edu.mx/comunidad/images/imagotipos/FTI_Color.png)

## Introducción
> Proyecto final para la creación de una máquina virtual con RancherOS en la cual se crearan los contenedores necesarios para crear una solución de ELK Stack (Elasticsearch, Logstash y Kibana) a partir de la información de una base de datos en MySQL (classicmodels + gfasales).

## Creación de una maquina virtual con docker-machine
### Instalación de Docker Machine en Windows

1. Verificar que ese deshabilitado el soporte para **Hyper-V** desde *Activar o desactivar las características de Windows* en Panel de Control. 
   - Para algunos casos verificar que esten deshabilitadas las opciones *Virtual Machine Platform* y *Windows Hypervisor Platform*.
2. Descargar e instalar [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
>
3. Ejecutar **PowerShell** con privilegios de administrador: 
``` 
bcdedit /set hypervisorlaunchtype off 
```
4. Instalar [Docker Desktop](https://www.docker.com/products/docker-desktop) para todos los usuarios y reiniciar.
>
5. Ejecutar **PowerShell** con privilegios de administrador e instalar **Chocolatey**: 
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
docker-machine env *nombre_VM* | Ver la configuración de una VM
docker-machine start *nombre_VM* | Iniciar una VM
docker-machine stop *nombre_VM* | Detener una VM
docker-machine rm -y *nombre_VM* | Eliminar una VM sin confirmación
docker-machine ssh *nombre_VM* | Conectarse a una VM a traves de SSH

### Configuración de la máquina virtual para la creación de los contenedores 
1. Verificar la IP asignada a la máquina virtual creada:
``` 
docker-machine env elk-stack
``` 
2. En el archivo host (%windir%\System32\drivers\etc\host) de la máquina local agregar la IP asignada para la URL de Kibana:
``` 
XXX.XXX.XXX.XXX	kibana.midominiomtie.net
``` 
3. Conectarse a la máquina virtual creada en el paso anterior:
``` 
docker-machine ssh elk-stack 
``` 
4. Cambiar a la consola de Ubuntu en RancherOS:
``` 
sudo ros console switch ubuntu 
``` 
5. Crear y editar el archivo **deploy.sh** en el directorio principal:
   1. Ejecutar `sudo vim deploy.sh`
   2. Presionar [ESC] + [i] para insertar.
   3. Pegar el contenido del archivo *deploy.sh* que se encuentra en el repositorio de Git.
   4. Guardar y salir. Presionar [ESC] y después escribir `:wq` (*write* y *quit*).
6. Crear y editar el archivo **update.sh** en el directorio principal:
   1. Ejecutar `sudo vim update.sh`
   2. Presionar [ESC] + [i] para insertar.
   3. Pegar el contenido del archivo *update.sh* que se encuentra en el repositorio de Git.
   4. Guardar y salir. Presionar [ESC] y después escribir `:wq` (*write* y *quit*).

### Ejecución del script de despliegue
- Ejecutar el script de despliegue inicial:
```
sh deploy.sh
```
El script **deploy.sh** realizará las siguientes acciones:
>
- Agregar en el archivo de configuración **sysctl** la variable y el valor `vm.max_map_count=2621444`.
- Instalar docker-compose en RancherOS y cambiar los permisos a la carpeta generada durante la instalación:
``` 
sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
``` 
>
```
sudo chmod +x /usr/local/bin/docker-compose
```
- Crear un alias para ejecutar Git sin instalarlo:
``` 
alias git="docker run -ti --rm -v $(pwd):/git bwits/docker-git-alpine" 
```
- Eliminar el repositorio local en caso de que exista.
- Clonar el repositorio de este proyecto en la máquina virtual:
``` 
git clone https://github.com/mdarkslide/MTIE_SOA_CICD_mom615246.git
``` 
- Limpiar los directorios *data* y *volumes*.
- Crear una carpeta para elasticsearch dentro de la carpeta del proyecto y darle los permisos necesarios. Actualizar el contenido de *data* y *volumes*. Copiar los archivos a la raiz desde la carpeta donde se encuentra el proyecto **MTIE_SOA_CICD_mom615246** en la cual se encuentra el archivo YAML **docker-compose.yaml** que contiene todas las instrucciones para la creación de los contenedores para este proyecto:
> 
Contenedor | Descripción
------------ | -------------
MRSI-Proxy | API Gateway Reverse Proxy Container
MRSI-MySQL | MySQL Container
MRSI-ElasticSearch | ElasticSearch Container
MRSI-Logstash | Logstach Container
MRSI-Kibana | Kibana Container

- Finalmente ejecuta el docker-compose y despliega los contenedores:
``` 
sudo docker-compose up --build -d
``` 
>
### Acciones del script de actualización
- Ejecutar el script de despliegue inicial:
```
sh update.sh
```
El script **update.sh** realizará las siguientes acciones:
- Crear un alias para ejecutar Git sin instalarlo:
``` 
alias git="docker run -ti --rm -v $(pwd):/git bwits/docker-git-alpine" 
```
- Eliminar el repositorio local en caso de que exista.
- Clonar el repositorio de este proyecto en la máquina virtual
``` 
git clone https://github.com/mdarkslide/MTIE_SOA_CICD_mom615246.git
``` 
- Actualizar los directorios *data* y *volumes*.
- Ejecutar el docker-compose para el despliegue de los contenedores:
``` 
sudo docker-compose up --build -d
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

Acceder a la interfaz de Kibana a través de un navegador:
>
[kibana.midominiomtie.net](http://kibana.midominiomtie.net/)
## Recursos
> Los detalles de este proyecto se describen en el siguiente articulo: [How to synchronize Elasticsearch with MySQL](https://towardsdatascience.com/how-to-synchronize-elasticsearch-with-mysql-ed32fc57b339)
- Inspirado en [How to keep Elasticsearch synchronized with a relational database using Logstash and JDBC](https://www.elastic.co/blog/how-to-keep-elasticsearch-synchronized-with-a-relational-database-using-logstash). Sin embargo, este artículo no describe como manejar el index desde el *scratch* y los registros borrados.
- Los datos utilizados para este proyecto estan disponibles en *Kaggle dataset* [Goodreads-books](https://www.kaggle.com/jealousleopard/goodreadsbooks)
- [Logstash JDBC input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-jdbc.html)
- [Logstash Mutate filter plugin](https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html)
- [Logstash Elasticsearch output plugin](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html)
- [MySQL classicmodels sample databae](https://www.mysqltutorial.org/mysql-sample-database.aspx)
## Agradecimientos
Gracias a todo el equipo de la Maestría en Tecnologías de la Información Empresarial, ¡Sin ustedes esto no habría sido posible!
## Fin del documento.