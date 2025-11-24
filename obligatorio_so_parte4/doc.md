# DECISIONES IMPLEMENTADAS
- Decidimos usar CMD en vez de EntryPoint 

- Se creó bloque upstream con web1 y web2, permitiendo que Nginx distribuya carga entre los 2 servidores. 
- puerto 5000 viendo que server.js "escucha" en el mismo y utiliza redis. 
- Uso de depends_on: 
-Exposición externa solo con 8080->80.



# Arquitectura implementada
 - Para la arquitectura se utilizan microservicios vistos en clase como Docker Compose. 
 - El servicio se divide en 4 contenedores : web1, web2 , redis y nginx. La decisión de crear dos
 contenedores para la web es para soportar el balance de carga que indicaba la letra. Esto lo hacemos con un bloque upstream en nginx.conf. 


 - Para los puertos utilizamos: 5000 (basandonos en donde hace listen server.js)
 - 

# Comunicación entre servicios 
- En server.js se llama a redis.createClient definiendo: 
  host: 'redis',
  port: 6379, 
  de esta manera las instancias web dependen de redis. 

- Para el orden correcto: 
- uso de depends_on : en nginx de los 2 web, y los 2 web de redis. 
- nginx se encarga con el upstream de ser el balanceador de carga de los 2 server web. Distribuyendo solicitudes a instancias distintas.



# Ventajas y desventajas de la solución implementada
- Escalabilidad Horizontal real: Esto es una buena ventaja ya que como definimos 2 instancias web distintas, nuestro sistema maneja mejor el trafico que si hubiese una sola. 
- Aislamiento: Como vemos web, redis, nginx corren un contenedor distinto, esto evita sobrecarga y asegura que en caso de que uno falle los otros no se vean afectados.
- Persistencia: con el uso de volumes en redis nos garantizamos que aunque se apaguen los contenedores los datos no se pierdan.  
- Además con docker compose up cualquiera puede levantar los contenedores. 


# Propuestas de mejora para entorno real 
 - uso de .env 
 - volumenes distribuidos redis? 
 - Kubernetes creado por google, usa escalado horizontal automatico. 
 - ejecutar más instancias de Nginx. 


# Diagrama 
