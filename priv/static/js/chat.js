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

  selectedRoom = "default"
  function sendMessage() {
    var messageBoxInput = document.getElementById("message-box-input");
    request = {
      room: selectedRoom,
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
  var username;
  function init() {
    output = document.getElementById("output");
    testWebSocket();
  }
  function testWebSocket() {
    username = extractUsername(getParameterByName("access_token"))
    console.log("this is the name:", name)
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
    console.log(response);
  
    if (isError(response)) {
      var createRoomSection = document.getElementById("create-room-section");
      var errorMessage = document.createElement("div");
      errorMessage.innerHTML = '<span style="color: red;">ERROR: ' + response.error + '</span>';
      createRoomSection.appendChild(errorMessage);
    } else if (isSuccess(response)) {
      var createRoomSection = document.getElementById("create-room-section");
      var successMessage = document.createElement("div");
      successMessage.innerHTML = '<span style="color: green;">Good: ' + response.success + '</span>';
      createRoomSection.appendChild(successMessage);
    } else if (isSystemMessage(response)) {
      if(response.cod == "100") // unirse a una sala a la que no te has unido
      {
        var createRoomSection = document.getElementById("create-room-section");
        var systemMessage = document.createElement("div");
        systemMessage.innerHTML = '<span style="color: gray;"> Joined to: ' + response.room + '</span>';
        createRoomSection.appendChild(systemMessage);

        // add button
        var joinRoomSection = document.getElementById("room-section");
        var joinRoomButton = document.createElement("button");
        joinRoomButton.innerHTML = response.room;
        joinRoomButton.className = 'room-access-button';
        joinRoomButton.id = response.room
        joinRoomButton.onclick = function () {
          accessRoom(joinRoomButton.id);
        };
        joinRoomSection.appendChild(joinRoomButton);

        var container = document.getElementById("message-container");
        var roomDiv = document.createElement("div");
        roomDiv.id = response.room + "-room";
        roomDiv.className = "room"
        container.appendChild(roomDiv);

      }
      else{ // ya unido a la sala 200
        var createRoomSection = document.getElementById("create-room-section");
        var systemMessage = document.createElement("div");
        systemMessage.innerHTML = '<span style="color: gray;"> you have already joined the room: ' + response.room + '</span>';
        createRoomSection.appendChild(systemMessage);
      }
    } else {
      console.log(response)
      var messageClass = response.from === username ? 'user-message' : 'other-user-message';
      writeToScreen('<span style="font-weight: bold;">' + response.from + ':</span> ' + response.message, messageClass, response. room);
    }
  }

  function accessRoom(roomName) {
    // Ocultar todos los divs con la clase 'room'
    console.log("clicked ", roomName)
    var allRoomDivs = document.querySelectorAll('.room');
    allRoomDivs.forEach(function (div) {
      div.style.display = 'none';
    });
    selectedRoom = roomName
    // Mostrar el div específico de la sala a la que se accede
    var accessedRoomDiv = document.getElementById(roomName + '-room');
    accessedRoomDiv.style.display = 'block';
  }
  
  
  function onError(evt) {
    writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data);
  }
  function doSend(message) {
    //writeToScreen("SENT: " + message);
    websocket.send(message);
  }
  function writeToScreen(message, messageClass, room) {
    // var container = document.getElementById("message-container");
    var roomDiv = document.getElementById(room+"-room")

    var messageDiv = document.createElement("div");
    messageDiv.className = "message " + messageClass;
  
    var messageSpan = document.createElement("span");
    messageSpan.innerHTML = message;
  
    messageDiv.appendChild(messageSpan);
    roomDiv.appendChild(messageDiv);
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

    console.log("system messg:",response)
    return response.cod != undefined
  }
  /* From: https://stackoverflow.com/a/5158301 */
  function getParameterByName(name) {
    var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
  }

  function extractUsername(token) {
    return token ? token.split("_")[0] : null;
  }

  function logout() {
    // Redirige a la página principal (puedes ajustar la URL según tu estructura)
    window.location.href = "/";
  }

  function checkEnterMessage(event) {
    if (event.key === 'Enter') {
      sendMessage();
    }
  }

  