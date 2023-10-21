defmodule Linguex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Nosedrum.TextCommand.Storage.ETS,
      # Linguex.Discord.ReadyState,
      # Linguex.Discord.Consumer,
      {Linguex.Agents.Alamedya, name: Linguex.Agents.Alamedya},
      LinguexWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Linguex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
