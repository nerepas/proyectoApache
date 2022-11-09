# Proyecto Apache
#### Nerea Pascual García

## Estructura
Para comenzar creamos una carpeta en la que contendremos todo el proyecto.
En esta crearemos a su vez varias subcarpetas: **confApache**, **confDNS**, **SitioSSL** y **html**.
Además crearemos un fichero llamado **docker-compose.yml**.

## Creación de ficheros  de prueba
Dentro de la carpeta html crearemos un fichero llamado **index.html** y otro llamado **info.php**.

En index.html escribiremos lo siguiente:
~~~
<h1>Hola mundo</h1>
~~~

En info.php lo siguiente:
~~~
<?php
    phpinfo();
    echo "Hola";
?>
~~~

## Docker-compose
El fichero docker-compose.yml lo modificaremos de la siguiente forma:
~~~
version: '3.9'
services:
asir_apache:
image: 'php:7.4-apache'
container_name: asir_apache
ports:
- '80:80'
    volumes:
    - ./html:/var/www/html
~~~

Utilizaremos el comando *docker-compose up*. Con esto, crearemos nuestro contenedor asir_apache y cargaremos la imagen indicada.

## Prueba de funcionamiento
Para comprobar que el index.html y el info.php funcionan correctamente nos iremos a nuestro navegador y utilizaremos las siguientes rutas.
Para comprobar el index.html usaremos *localhost*. Nos devolverá lo siguiente:

![](imagenes/index.png)

Para comprobar el info.php usaremos *localhost/info.php*. Nos devolverá lo siguiente:

![](imagenes/info.png)

## Volumen Apache2
Modificamos el docker-compose.yml y añadimos lo siguiente:
~~~
volumes:
  confApache:
~~~
Quedará de la siguiente forma:
~~~
version: '3.9'
services:
asir_apache:
image: 'php:7.4-apache'
container_name: asir_apache
ports:
- '80:80'
volumes:
- ./html:/var/www/html
- confApache:/etc/apache2
volumes:
confApache:
~~~

A continuación copiaremos todos los ficheros del volumen apache2 en nuestra carpeta ConfApache con el comando:
*docker cp asir_apache:/etc/apache2 .*

## Sitios
Dentro de la carpeta html creamos la carpeta Site1 y Site2. Movemos el archivo index.html a la carpeta Site2.
Creamos dentro de la carpeta Site2 un archivo llamado index.php en el que contendremos lo siguiente:
~~~
<?php
echo "Hola desde el sitio2";
?>
~~~

Cambiamos el docker-compose y el segundo volumen (ConfApache) lo modificaremos de la forma: ./ConfApache para que coja nuestra carpeta COnfApache.
También añadiremos en los puertos:
'8000:8000'
Quedará de la siguiente forma:
~~~
version: '3.9'
services:
  asir_apache:
    image: 'php:7.4-apache'
    container_name: asir_apache
    ports:
    - '80:80'
    - '8000:8000'
    volumes:
    - ./html:/var/www/html
    - ./confApache:/etc/apache2
volumes:
    confApache:
~~~

Entramos en la carpeta ConfApache y posteriormente en sites-available y modificaremos el fichero llamado 000-default.conf. Cmbiaremos la linea:
DocumentRoot /var/www/html/Site1

Creamos una copia de este fichero en la misma ubicación y lo renombraremos a 002-default.conf.
Cambiamos las siguientes lineas en el fichero:
VirtualHost *:8000
DocumentRoot /var/www/html/Site2

Con el contenedor arrancado hacemos click derecho sobre este y seleccionamos Attach Visual Studio Code. En la nueva ventana abrimos una terminal e introducimos lo siguiente:
*cd /var/www/html/*
*a2ensite 002-default*

Esto hará que se cree en sites-enable el fichero correspondiente a 002-default.

En el fichero ports.conf añadiremos la linea:
Listen 8000
Esto hará que se pueda escuchar en el puerto del sitio 2.

Borramos en el docker compose las siguientes lineas:
volumes:
    confApache:
Quedará de la siguiente forma:
~~~
version: '3.9'
services:
  asir_apache:
    image: 'php:7.4-apache'
    container_name: asir_apache
    ports:
    - '80:80'
    - '8000:8000'
    volumes:
    - ./html:/var/www/html
    - ./confApache:/etc/apache2
~~~

Paramos y arrancamos de nuevo el contenedor para que se apliquen todos los cambiamos realizados.

## Prueba de funcionamiento de Sitios
Para comprobar que funciona nos iremos al navegador y escribiremos lo siguiente.

En caso del sitio1: localhost

Nos mostrará lo siguiente:

![](imagenes/indexsitio1.png)

En el caso del sitio2: localhost:8000

Nos mostrará lo siguiente:

![](imagenes/indexsitio2.png)
