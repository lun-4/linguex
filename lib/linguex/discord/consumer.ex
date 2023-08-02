defmodule Linguex.Discord.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nosedrum.TextCommand.Storage.ETS, as: CommandStorage
  alias Nosedrum.TextCommand.Invoker.Split
  alias Linguex.Discord.ReadyState

  require Logger

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    self_id = ReadyState.user_id()

    unless msg.author.id == self_id do
      # if the message starts with an user id mention, then it's time to talk to the  llm
      try do
        if for_assistant(msg, self_id) do
          handle_assistant(msg, self_id)
        else
          handle_non_assistant(msg)
        end
      rescue
        e ->
          Logger.error(Exception.format(:error, e, __STACKTRACE__))
          Api.create_message!(msg.channel_id, "error happened: #{inspect(e)}")
          reraise e, __STACKTRACE__
      end
    end
  end

  defp for_assistant(msg, self_id) do
    # TODO add message cache for reply detection / thread construction
    unless msg.mentions
           |> Enum.filter(fn user -> user.id == self_id end)
           |> Enum.count() ==
             0 do
      String.starts_with?(msg.content, "<@#{self_id}>") or
        String.starts_with?(msg.content, "<@!#{self_id}>")
    else
      false
    end
  end

  defp handle_assistant(msg, self_id) do
    input_prompt =
      msg.content
      |> String.replace("<@#{self_id}>", "")
      |> String.replace("<@!#{self_id}>", "")
      |> String.strip()

    # TODO strip mentions from message
    reply = Linguex.DefaultPipeline.submit(input_prompt)
    Api.create_message!(msg.channel_id, "#{inspect(reply)}")
  end

  defp handle_non_assistant(msg) do
    case Split.handle_message(msg) do
      {:error, {:unknown_subcommand, _name, :known, known}} ->
        Api.create_message(
          msg.channel_id,
          "🚫 unknown subcommand, known subcommands: `#{Enum.join(known, "`, `")}`"
        )

      {:error, :predicate, {:error, reason}} ->
        Api.create_message(msg.channel_id, "❌ cannot evaluate permissions: #{reason}")

      {:error, :predicate, {:noperm, reason}} ->
        Api.create_message(msg.channel_id, reason)

      _ ->
        :ok
    end
  end

  def handle_event({:READY, msg, _ws_state}) do
    Logger.info("ready!")
    CommandStorage.add_command(["ping"], Linguex.Discord.Cogs.Ping)
    CommandStorage.add_command(["eval"], Linguex.Discord.Cogs.Eval)
    Logger.info("#{inspect(msg)}")
    ReadyState.set(msg)
    :ok
  end

  def handle_event(_event) do
    :noop
  end
end
