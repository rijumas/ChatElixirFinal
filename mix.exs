defmodule ExChat.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_chat,                              # Nombre del proyecto: ex_chat
      version: "0.1.0",                           # Versión del proyecto
      elixir: "~> 1.6",                           # Versión de Elixir
      start_permanent: Mix.env() == :prod,        # Iniciar permanentemente en producción
      aliases: aliases(),                         # Alias para ejecutar tareas
      deps: deps()                                # Dependencias
    ]
  end

  def application do
    [
      #extra_applications: [:cowboy, :plug, :logger],    # Aplicaciones extra: logger (manejo de errores)
      extra_applications: applications(Mix.env),       # Aplicaciones extra: logger (manejo de errores

      mod: {ExChat, []}                                 # Módulo principal: ExChat
    ]
  end

  defp applications(:dev), do: applications(:all) ++ [:remix]
  defp applications(_all), do: [:cowboy, :plug, :logger]

  def aliases do
    [
      test: "test --no-start"                     # Alias para ejecutar pruebas
    ]
  end

  defp deps do
    [
      # Web requests
      {:cowboy, "~> 2.4"},                        # Dependencia: cowboy (servidor web)
      {:plug, "~> 1.6"},                          # Dependencia: plug (manejador de peticiones)
      {:poison, "~> 3.1"},                        # Dependencia: poison (manejador de JSON)
      {:websockex, "~> 0.4.0", only: :test},      # Dependencia: websockex (manejador de websockets)
      {:mock, "~> 0.3.3", only: :test},           # Dependencia: mock (manejador de mocks)

      # Developments
      {:remix, "~> 0.0.2", only: :dev}            # Dependencia: remix (manejador de tareas)
    ]
  end
end
