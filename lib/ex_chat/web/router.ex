
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


  get "/original" do
    send_resp(conn, 200, "Esta es la página original")
  end

  get "/redireccion" do
    conn
    |> put_resp_header("location", "/original")
    |> send_resp(302, "")
  end

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
