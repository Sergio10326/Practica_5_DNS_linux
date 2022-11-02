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



