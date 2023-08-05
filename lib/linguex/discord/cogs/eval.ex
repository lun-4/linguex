defmodule Linguex.Discord.Cogs.Eval do
  @behaviour Nosedrum.Command
  @moduledoc false

  @impl true
  def usage, do: ["eval"]

  @impl true
  def description, do: "eval lmao"

  @impl true
  def parse_args(args), do: Enum.join(args, " ")

  def is_admin(message) do
    admin_id = Application.get_all_env(:nostrum)[:admin_id]

    if message.author.id == admin_id do
      :passthrough
    else
      {:noperm, "sorry, only admin allowed (atm configured with admin_id=#{admin_id})"}
    end
  end

  @impl true
  def predicates, do: [&is_admin/1]

  def command(msg, args) do
    args
    |> then(fn string_to_eval ->
      Code.eval_string(
        "import IEx.Helpers\n" ++ string_to_eval,
        [msg: msg, recompile: &IEx.Helpers.recompile/0],
        __ENV__
      )
    end)
    |> then(fn {result, _} ->
      {:ok, _} = Nostrum.Api.create_message(msg.channel_id, "`#{inspect(result)}`")
    end)
  end
end
