<<<<<<< HEAD
# Práctica 1 -DNS Linux Sergio De La Iglesia Lorenzo

1. Volumen por separado de la configuración

Para hacer el volumen por separado de la configuración, hay que dividir el .conf en otros dos archivos, uno para la configuración del DNS y el otr para crear la zona por cada vez que se lance. Para conseguir eso, hay que añadir las siguientes líneas: 

```
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local"; 

```
2. Red propia interna para todos los contenedores

Crear una red interna en la que almacenar tanto el servidor como el cliente DNS se hace mediante el archivo de creación de los contenedores de docker-compose. Dentro de este, hay que añadir el apartado "networks", asignarle el nombre que se quiera y la IP de la red. Tras haberla creado, ya en el apartado del cliente, hay que añadir también en el apartado "networks" el nombre de la subred hecha anteriormente. No hace falta asignar una IP ya que estp se hará por DHCP. El resultado sería así: 

```
version: "3.3"
services:
  asir_bind9:
    container_name: asir_bind9
    image: internetsystemsconsortium/bind9:9.16
    volumes:
      - /home/asir2a/Escritorio/SRI/bind9/conf:/etc/bind
      - /home/asir2a/Escritorio/SRI/bind9/zonas:/var/lib/bind
    networks:
      bind9_subnet:
        ipv4_address: 10.1.0.254 
  asir_cliente:
    container_name: asir_cliente
    image: alpine
    networks:
      - bind9_subnet
    stdin_open: true # docker run -i
    tty: true        # docker run -t
    dns:
      - 10.1.0.254   # el contenedor dns server 
networks:
  bind9_subnet:
    external: true
```

3. IP fija en el servidor

Para poner la IP fija en el servidor, hay que asignarla en el apartado "networks", como ya hice en el apartado anterior, siendo en este caso la 10.1.0.254.

4. Configurar Forwarders

Los "Forwarders" son los servidores DNS a los que recurrirá el que estamos creando en caso de que no tenga en su base de datos un nombre, y lo buscará en este. Para hacer esta configuración, solo hay que poner la IP del servidor DNS que usaremos en el apartado Forwarders. El resultado sería el siguiente:

```
options {
    directory "/var/cache/bind";

    forwarders {
        1.1.1.1;
    };
    // forward only;

    listen-on { any; };
    listen-on-v6 { any; };
    allow-query {
        any;
    };
};
```

5. Crear zona propia

La creación de la zona propia se divide en 2 partes principales, la primera en la formación del archivo .conf.local, que es propio de las zonas, y el archivo de la zona en sí. En el primero se crea el nombre de la zona, junto a la ubicación del contenedor donde estará almacenada, etc. El resultado sería algo así:

```
zone "asircastelao.com" {
    type master;
    file "/var/lib/bind/db.asircastelao.com";
    allow-query {
        any;
    };
};
```
En cuanto al archivo de la zona en sí, es en el que se añaden las opciones que pueden funcionar en el servidor, como los servicios que pueden usarse en el servidor, los tiempos de vida, etc. El resultado de este sería el siguiente:

```
$TTL    3600
@       IN      SOA     ns.asircastelao.com. sdelaiglesialorenzo.danielcastelao.org. (
                   2022021002           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@       IN      NS      ns.asircastelao.com.
@       IN      MX      10 servidorcorreo.asircastelao.org.
@       IN      CNAME   ns.asircastelao.com/subdomain
@       IN      TXT     ns.asircastelao.com.
@       IN      SOA     ns.asircastelao.com.

ns     IN      A       10.1.0.254
etch    IN      A       10.1.0.2

pop.asircastelao.com.     IN      CNAME   ns
www.asircastelao.com.      IN      CNAME   etch
mail.asircastelao.com.     IN      CNAME   etch
```

6. Cliente con herramientas de red



=======
## Práctica 1-DNS Linux

### Líneas de docker-compose explicadas:

1. Services: es el apartado que sirve para abrir las diferentes opciones de configuración que voy a explicar a continuación.

2. asir_bind9 y asir_cliente: son las subdivisiones de los servicios que se van a montar. No son equivalentes ni al número de contenedores ni al nombre.

3. container_name: se escoge el nombre para crear un contenedor.

4. image: se selecciona la imagen que se va a usar para crear el contenedor, pudiendo ser propia o de una página externa

5. volumes: se asignan las posiciones de memoria y se mapea la ruta del host con las posiciones del contenedor que se está creando. 

6. networks: es la asignación de la red para los contenedores es necesario antes de ejecutar el comando "docker-compose up" crear la red, ya que el valor external al ser "true", exige que la red esté creada de antes.   

7. stdin_open: true: esta opción permite abrir una shell dentro del contenedor en sí. Esto permite comprobar que funcione correctamente el servidor DNS

8. tty: true: esta línea permite que el contenedor se mantenga en ejecución tras haberlo creado.

9. DNS: esta línea sirve para especificar la dirección del servicio DNS que va a usar el contenedor.

### Procedimiento de creación de servicios

Para crear los servicios, es necesario dividir las opciones de configuración en dos archivos por separado, que se les pone de nombre "named.conf.options" y "named.conf.local". Esto se hace para dividir la configuración del servicio de DNS y las zonas, que van aparte. Esta configuración se hace con "include" y En el siguiente apartado es en el que explico más en detalle el contenido de estos dos archivos extra.

### Modificación de la configuración, arranque y parada de servicio bind9

La modificación de la configuración consiste en modificar los archivos de la configuración para que otorgen el servicio. En el caso de "named.conf.options", especifica las opciones del servidor DNS, como los servidores que va a usar de Forwarders, es decir, a los que va a recurrir en caso de que no encuentre la correspondencia por el nombre, etc. En el caso del archivo "named.conf.local" es para configurar las opciones de la zona, como el path del contenedor en el que va a estar la configuración, el nombre del servidor, los clientes autorizados, etc.

El procedimiento para arrancar el servicio es muy simple: hay que ejecutar el comando "docker-compose up" y ya se crean los contenedores tanto del cliente como del servidor. Para parar únicamente el contenedor del bind9, hay que darle botón derecho encima del contenedor y usar la opción "Stop". Esto permite parar solo es servicio y mantener el cliente activo.

### Configuración de la zona y cómo comprobar si funciona

En la zona, hay varias opciones que se deben añadir para que funcione correctamente. La primera es el TTL (Time To Live), que es el tiempo en segundos que durará la página sin necesidad de hacer una nueva consulta o actualizarse. Tras ello, varias de las opciones principales de configuración son el CNAME,SOA,NS,TXT,MX y A. Estas siven para proporcionar diferentes servicios, como el de correo electrónico con MX, la configuración de la IP de la red interna con A, el SOA para el registro de la autoridad, a la cual hay que darle una dirección de correo, el NS para declarar el nombre del dominio que aplicará el servicio,el CNAME, que sirve para crear un alias para el dominio, y por último el TXT, que sirve para añadir texto e información sobre el dominio.

Para comprobar que funciona correctamente el servicio, hay que abrir una shell y hacer el comando "ping" a una IP, como la 8.8.8.8. Si se hace, funciona correctamente.


>>>>>>> 80c6812d3cb7b92e0269945c90e4850c2c82d539
