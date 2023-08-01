defmodule Linguex.Discord.Cogs.Ping do
  @behaviour Nosedrum.Command
  @moduledoc false

  @impl true
  def usage, do: ["ping"]

  @impl true
  def description, do: "ping lmao"

  @impl true
  def predicates, do: []

  def command(msg, _args) do
    {:ok, _msg} = Nostrum.Api.create_message(msg.channel_id, "pong!")
  end
end
