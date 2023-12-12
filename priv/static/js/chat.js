   /* UI functions */
   function createRoom() {
    var messageBoxRoomInput = document.getElementById("create-room-input");
    request = {
      command: "create",
      room: messageBoxRoomInput.value
    }
    doSend(JSON.stringify(request))
  }
  function joinRoom() {
    var messageBoxRoomInput = document.getElementById("join-room-input");
    request = {
      command: "join",
      room: messageBoxRoomInput.value
    }
    doSend(JSON.stringify(request))
  }

  function sendMessage() {
    var messageBoxRoomInput = document.getElementById("message_box_room_input");
    var messageBoxInput = document.getElementById("message_box_input");
    request = {
      room: message_box_room_input.value,
      message: messageBoxInput.value
    }
    console.log(request)
    doSend(JSON.stringify(request))
    messageBoxInput.value = "";
  }

  /* WebSockets functions */
  var wsUri = "ws://" + location.host + "/chat";
  var output;
  var websocket;

  function init() {
    output = document.getElementById("output");
    testWebSocket();
  }
  function testWebSocket() {
    websocket = new WebSocket(wsUri + "?access_token=" + getParameterByName("access_token"));
    websocket.onopen = function(evt) { onOpen(evt) };
    websocket.onclose = function(evt) { onClose(evt) };
    websocket.onmessage = function(evt) { onMessage(evt) };
    websocket.onerror = function(evt) { onError(evt) };
  }

  var isConnected = false;

  function onOpen(evt) {
    if (!isConnected) {
      document.getElementById("connection-status").textContent = "Connected";
      document.getElementById("connection-status").classList.remove("disconnected");
      document.getElementById("connection-status").classList.add("connected");
      isConnected = true;
    }
  }
  
  function onClose(evt) {
    document.getElementById("connection-status").textContent = "Disconnected";
    document.getElementById("connection-status").classList.remove("connected");
    document.getElementById("connection-status").classList.add("disconnected");
    isConnected = false;
  }
  function onMessage(evt) {
    response = JSON.parse(evt.data);
    console.log(response)
    
    if (isError(response)) {
      writeToScreen('<span style="color: red;">ERROR: ' + response.error + '</span>');
    } else if (isSuccess(response)) {
      writeToScreen('<span style="color: green;">SUCCESS: ' + response.success + '</span>');
    } else if (isSystemMessage(response)) {
      writeToScreen('<span style="color: gray;">' + response.room +': ' + response.message + '</span>');
    } else {
      writeToScreen('<span style="color: blue;">' + response.from + ' : ' + response.message + '</span>');
    }
  }
  function onError(evt) {
    writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data);
  }
  function doSend(message) {
    //writeToScreen("SENT: " + message);
    websocket.send(message);
  }
  function writeToScreen(message) {
    var pre = document.createElement("p");
    pre.style.wordWrap = "break-word";
    pre.style.backgroundColor = "rgba(200, 200, 200, 0.8)"; // Fondo semi-transparente gris claro
    pre.style.padding = "10px"; // Ajusta el espacio interno según tus preferencias
    pre.style.borderRadius = "8px"; // Bordes curvos
    pre.innerHTML = message;
    output.appendChild(pre);
  }
  window.addEventListener("load", init, false);

  /* Helper functions */
  function isError(response) {
    return response.error != undefined
  }
  function isSuccess(response) {
    return response.success != undefined
  }
  function isSystemMessage(response) {
    return response.from == undefined
  }
  /* From: https://stackoverflow.com/a/5158301 */
  function getParameterByName(name) {
    var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
  }

  function logout() {
    // Redirige a la página principal (puedes ajustar la URL según tu estructura)
    window.location.href = "/";
  }