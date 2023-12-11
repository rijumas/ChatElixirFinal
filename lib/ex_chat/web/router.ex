
defmodule ExChat.Web.Router do
  use Plug.Router
  import Plug.Conn

  plug Plug.Static, at: "/", from: :ex_chat

  plug :match
  plug :dispatch


  match "/" do
    login_file_path = "priv/static/login.html"
    login_content = File.read!(login_file_path)
    html_response(conn, login_content)
  end


  match "/register", [:post] do
    case Plug.Conn.read_body(conn, length: :infinity) do
      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok, %{"username" => username, "password" => password}} ->
            IO.inspect(username, label: "Username")
            IO.inspect(password, label: "Password")

            # Almacena el usuario y la contraseña en el proceso GenServer
            ExChat.GlobalListUC.add_element(%{"username" => username, "password" => password})

            user_listUS = ExChat.GlobalListUS.get_list()
            IO.inspect(user_listUS, label: "Lista de usuarios despues del registro:")

            user_listUC = ExChat.GlobalListUC.get_list()
            IO.inspect(user_listUC, label: "Lista de usuarios despues del registro:")

            #añadiendo sesiones de usuario

            ExChat.UserSessions.create(username)
            ExChat.AccessTokenRepository.add("#{username}_token", username)

            send_resp(conn, 200, "Datos del formulario recibidos con éxito")
          {:error, reason} ->
            IO.inspect("Error al parsear JSON: #{reason}")
            send_resp(conn, 400, "Error al parsear JSON: #{reason}")
        end

      {:error, reason, conn} ->
        IO.inspect("Error al leer el cuerpo del formulario: #{reason}")
        send_resp(conn, 400, "Error al leer el cuerpo del formulario: #{reason}")
    end
  end

  match "/login", [:post] do
    case Plug.Conn.read_body(conn, length: :infinity) do
      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok, %{"username" => username, "password" => password}} ->

            # Verifica las credenciales en ExChat.GlobalListUC
            if ExChat.GlobalListUC.valid_credentials?(%{"username" => username, "password" => password}) do
              # Si las credenciales son válidas, construye el JSON con la URL
              IO.inspect("Login")
              IO.inspect(username, label: "Username")
              IO.inspect(password, label: "Password")
              redirect_url = "/meta_chat?access_token=#{username}_token"
              json_response = Jason.encode!(%{"redirect_url" => redirect_url})
              IO.inspect(json_response, label: "JSON response")
              send_resp(conn, 200, json_response)
            else
              send_resp(conn, 401, "Credenciales incorrectas")
            end
          {:error, reason} ->
            IO.inspect("Error al parsear JSON: #{reason}")
            send_resp(conn, 400, "Error al parsear JSON: #{reason}")
        end

      {:error, reason, conn} ->
        IO.inspect("Error al leer el cuerpo del formulario: #{reason}")
        send_resp(conn, 400, "Error al leer el cuerpo del formulario: #{reason}")
    end
  end

  get "meta_chat" do
    chat_file_path = "priv/static/chat.html"
    chat_content = File.read!(chat_file_path)
    html_response(conn, chat_content)
  end

  # get "/original" do
  #   send_resp(conn, 200, "Esta es la página original")
  # end

  # get "/redireccion" do
  #   conn
  #   |> put_resp_header("location", "/original")
  #   |> send_resp(302, "")
  # end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp html_response(conn, html_content) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_content)
  end

  def dispatch do
    [
      {:_, [
        {"/chat", ExChat.Web.WebSocketController, []},
        {:_, Plug.Adapters.Cowboy2.Handler, {__MODULE__, []}}
      ]}
    ]
  end
end
