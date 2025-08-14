defmodule BasicApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BasicApp.Repo,
      {DNSCluster, query: Application.get_env(:basic_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BasicApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BasicApp.Finch},
      # Database setup task (after Repo is started)
      {Task, fn -> BasicApp.DatabaseSetup.setup!() end},
      # Start ExESDB system using UmbrellaHelper for proper isolation
      ExESDB.UmbrellaHelper.child_spec(:basic_app)
      # Start a worker by calling: BasicApp.Worker.start_link(arg)
      # {BasicApp.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BasicApp.Supervisor)
  end
end
