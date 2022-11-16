# Proyecto Apache
###### Nerea Pascual García

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
Dentro de la carpeta html creamos la carpeta Site1 y Site2. 
Movemos el archivo index.html a la carpeta Site1.
Creamos dentro de la carpeta Site2 un archivo llamado index.php en el que contendremos lo siguiente:
~~~
<?php
echo "Hola desde el sitio2";
?>
~~~

Cambiamos el docker-compose y el segundo volumen (ConfApache) lo modificaremos de la forma: 

./ConfApache 

para que coja nuestra carpeta ConfApache.

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

Entramos en la carpeta ConfApache y posteriormente en sites-available y modificaremos el fichero llamado 000-default.conf. 
Cambiaremos la linea:

DocumentRoot /var/www/html/Site1

Creamos una copia de este fichero en la misma ubicación y lo renombraremos a 002-default.conf.

Cambiamos las siguientes lineas en el fichero:

VirtualHost *:8000

DocumentRoot /var/www/html/Site2

Con el contenedor arrancado hacemos click derecho sobre este y seleccionamos Attach Visual Studio Code. 
En la nueva ventana abrimos una terminal e introducimos lo siguiente:

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

En caso del sitio1: *localhost*

Nos mostrará lo siguiente:

![](imagenes/indexsitio1.png)

En el caso del sitio2: *localhost:8000*

Nos mostrará lo siguiente:

![](imagenes/indexsitio2.png)

## DNS
Creamos una carpeta llamada **confDNS**. En ella crearemos 2 subcarpetas a las que nombraremos **config** y **zonas**.

Dentro de la carpeta config crearemos 3 ficheros.
El primero llamado *named.conf* donde incluiremos lo siguiente:

~~~
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
~~~

El segundo llamado *named.conf.local* donde incluiremos lo siguiente:

~~~
zone "fabulas.com." {
        type master;
        file "/var/lib/bind/db.fabulas.com";
        allow-query {
            any;
        };
};
~~~

Por último, el tercero llamado *named.conf.options* donde incluiremos lo siguiente:
~~~
options {
    directory "/var/cache/bind";
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    forward only;
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query {
        any;
    };
};
~~~

En la carpeta zonas creamos un fichero llamado *db.fabulas.com* donde incluiremos lo siguiente:

~~~
$TTL    3600
@       IN      SOA     ns.fabulas.com. nerea.fabulas.org. (
                   2007010401           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@       IN      NS      ns.fabulas.com.
@       IN      MX      10 servidorcorreo.fabulas.org.

ns     IN      A       10.1.0.254
etch    IN      A       123.123.4.5
pop     IN      CNAME   ns
www     IN      CNAME   etch
mail    IN      CNAME   etch

test    IN      A       10.1.0.2
alias   IN      CNAME   test
~~~


Con esto hecho, nos iremos a nuestro docker-compose.yml e incluiremos lo siguiente a la altura de asir_apache:

~~~
bind9:
    container_name: asir_bind9
    image: internetsystemsconsortium/bind9:9.16
    ports:
      - 5300:53/udp
      - 5300:53/tcp
    networks:
      bind9_subnet:
        ipv4_address: 10.1.0.254
    volumes:
      - /home/asir2a/Escritorio/SRI/proyectoApache/confDNS/config:/etc/bind
      - /home/asir2a/Escritorio/SRI/proyectoApache/confDNS/zonas:/var/lib/bind
  asir_cliente:
    container_name: asir_cliente
    image: alpine
    networks:
      - bind9_subnet
    stdin_open: true
    tty: true
    dns:
      - 10.1.0.254
networks:
  bind9_subnet:
    external: true
~~~

Con esto, hacemos un docker-compose up y todos los contenedores (asir_bin9, asir_cliente(alpine) y asir_apache) se levantarán.

### Comprobación de funcionamiento de DNS
Haremos click derecho sobre el contenedor Alpine y seleccionamos Attach shell.

A continuación, haremos *ping ns.fabulas.com* y si todo funciona correctamente, tendremos la comprobación de que el DNS está bien configurado.

Comprobación:

![](imagenes/dns.png)