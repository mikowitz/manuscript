defmodule Manuscript.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ManuscriptWeb.Telemetry,
      Manuscript.Repo,
      {DNSCluster, query: Application.get_env(:manuscript, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Manuscript.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Manuscript.Finch},
      # Start a worker by calling: Manuscript.Worker.start_link(arg)
      # {Manuscript.Worker, arg},
      # Start to serve requests, typically the last entry
      ManuscriptWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Manuscript.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ManuscriptWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
