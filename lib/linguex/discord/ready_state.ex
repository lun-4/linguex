defmodule Linguex.Discord.ReadyState do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def user_id do
    Agent.get(__MODULE__, fn msg ->
      msg.user.id
    end)
  end

  def set(msg) do
    Agent.update(__MODULE__, fn _ -> msg end)
  end
end
