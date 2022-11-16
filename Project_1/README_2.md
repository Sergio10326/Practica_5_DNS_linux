# Instalación de Apache+PHP con Docker

1. Busca una imagen ya hecha de apache con php en https://hub.docker.com/

La imagen a usar en este caso es la php:7.2-apache. Es la que se ha creado para que vaya de forma predeterminada el php en la imagen de apache.

```
image: php:7.2-apache
```

2. Utiliza docker-compose para configurar el contenedor.

Para poder usar docker-compose hay que crear un archivo en el directorio del proyecto que sea "docker-compose.yml" y configurarlo de forma que queden los puertos 80 del host y del servidor mapeados, al igual que hay que crear dos volúmenes para la configuración del apache y para alojar la información html.

```

version: "3.3"
services:
  asir_apache_php_server:
    container_name: asir_apache_php_server
    image: php:7.2-apache
    ports:
      - "80:80"
    volumes:
      - /home/asir2a/Escritorio/SRI/bind9/Project_1:/var/www/html:ro
      - confApache:/etc/apache2
volumes:
  confApache:

```

Los parámetros de esta parte son simples, lo más importante son los volúmenes y los puertos mapeados.

3. Mapea el "DocumentRoot" del apache con una carpeta local

Este paso ya lo explico en parte del anterior, ya que hay que mapear la ruta local que contiene el contenedor con la localización que va a tener dentro del contenedor el servicio HTML.

```
- /home/asir2a/Escritorio/SRI/bind9/Project_1:/var/www/html:ro
```

4. Realiza un "Hola mundo" en html y comprueba que funciona

Esto se puede hacer de 2 formas: la primera es llamando al documento index.html para que se reconozca su contenido de forma directa, o se puede cambiar la ruta de acceso mediante la URL. En este caso lo haré con el archivo index.html

![Imagen de comprobación: ](Images/cap.png)

5. Utiliza la función de phpinfo() para testear que el módulo de php funciona

Para hacer esto, simplemente hay que crear un archivo PHP que contenga la función phpinfo() y hay que acceder de forma manual a ese archivo especificando la ruta en el buscador, siendo el archivo a.php

```
<?php
phpinfo();
?>
```
