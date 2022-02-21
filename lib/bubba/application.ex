defmodule Bubba.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BubbaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bubba.PubSub},
      # Start the Endpoint (http/https)
      BubbaWeb.Endpoint
      # Start a worker by calling: Bubba.Worker.start_link(arg)
      # {Bubba.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bubba.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BubbaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
