defmodule RewardApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RewardApp.Repo,
      RewardAppWeb.Telemetry,
      {Phoenix.PubSub, name: RewardApp.PubSub},
      RewardAppWeb.Endpoint,
      RewardApp.Scheduler
      # RewardApp.Tasks.UpdateDatabase
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RewardApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RewardAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
