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


