defmodule Jurl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      JurlWeb.Telemetry,
      Jurl.Repo,
      {DNSCluster, query: Application.get_env(:jurl, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Jurl.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Jurl.Finch},
      # Start custom servers
      Jurl.Cache.URLCache,
      Jurl.Anonymous.SessionStore,
      Jurl.Anonymous.Limiter,
      Jurl.Analytics.ClickProcessor,
      # Start a worker by calling: Jurl.Worker.start_link(arg)
      # {Jurl.Worker, arg},
      # Start to serve requests, typically the last entry
      JurlWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jurl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JurlWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
