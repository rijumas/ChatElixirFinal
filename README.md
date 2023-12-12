# MetaChat

Es un chat web simple que utiliza websockets para el intercambio de los datos de mensajeria.

![the sketch](/sketch.png?raw=true)

## Caracteristicas

- **Registro del usuario:** Los nuevos clientes deben registrarse al sistema  
- **Inicio de sesión del usuario :** Los usuarios registrados ahora podran acceder al chat através del login.
- **Creación de salas:** En la parte del chat, se podran crear salas para que se puedan enviar mensajes através de estas.
- **Unirse a las salas:** Una vez creadas las salas, los usuarios deben unirse a estas, para enviar los mensajes.
- **Enviar mensajes:** Los usuarios enviaran mensajes en salas, y el sistema reenviara el mensaje a cada uno de los usuarios registrados en las salas.

## Ejecutar aplicación

```
$ mix deps.get
$ iex -S mix
```

## Como usar el chat

El sistema una vez ejecutado se desplagara y podra ser accedido por un navegador web através de la url: **http://localhost:4000**

## Muestra

# Registro
<img src="/images/register_02.png" alt="register" width="70%">

# Inicio de sesión
<img src="/images/SingIn_01.png" alt="login" width="70%">

# Creación de sala
<img src="/images/newRoom_01.png" alt="create_room" width="70%">

# Unirse a la sala
<img src="/images/newRoom_01.png" alt="join_room" width="70%">

# Enviar mensajes
<img src="/images/sendMsg_01.png" alt="send_message" width="70%">
