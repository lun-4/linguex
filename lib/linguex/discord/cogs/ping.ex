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
    start_time = System.monotonic_time(:millisecond)
    {:ok, ping_msg} = Nostrum.Api.create_message(msg.channel_id, "pong!")
    end_time = System.monotonic_time(:millisecond)

    send_latency_ms = end_time - start_time

    start_time = System.monotonic_time(:millisecond)
    {:ok, _} = Nostrum.Api.edit_message(ping_msg, "pong! send: `#{send_latency_ms}ms`")
    end_time = System.monotonic_time(:millisecond)
    edit_latency_ms = end_time - start_time

    {:ok, _} =
      Nostrum.Api.edit_message(
        ping_msg,
        "pong! send: `#{send_latency_ms}ms` edit: `#{edit_latency_ms}ms`"
      )
  end
end
