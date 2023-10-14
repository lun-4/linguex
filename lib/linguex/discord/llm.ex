defmodule Linguex.Discord.Cogs.LLM.Reset do
  @behaviour Nosedrum.Command
  @moduledoc false

  @impl true
  def usage, do: ["llm.reset"]

  @impl true
  def description, do: "reset history for current channel"

  @impl true
  def predicates, do: [&is_admin/1]

  def is_admin(message) do
    if message.author.id == 162_819_866_682_851_329 do
      :passthrough
    else
      {:noperm, "not admin lol"}
    end
  end

  def command(msg, _args) do
    Linguex.Agents.Alamedya.wipe_history(Linguex.Agents.Alamedya, msg.channel_id)

    Nostrum.Api.create_message!(
      msg.channel_id,
      ":ok"
    )
  end
end
