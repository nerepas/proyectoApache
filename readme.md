# Proyecto Apache
## Nerea Pascual García

Para comenzar creamos una carpeta en la que contendremos todo el proyecto.
En esta crearemos a su vez varias subcarpetas: **confApache**, **confDNS**, **Sitio1**, **Sitio2**, **SitioSSL** y **html**.
Además crearemos un fichero llamado **docker-compose.yml**.

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

Para comprobar que el index.html y el info.php funcionan correctamente nos iremos a nuestro navegador y utilizaremos las siguientes rutas.
Para comprobar el index.html usaremos *localhost*. Nos devolverá lo siguiente:

![](imagenes/index.png)

Para comprobar el info.php usaremos *localhost/info.php*. Nos devolverá lo siguiente:


