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

  defp message_content_filter(content, self_id) do
    content
    |> String.replace("<@#{self_id}>", "")
    |> String.replace("<@!#{self_id}>", "")
    |> String.strip()
  end

  defp handle_assistant(msg, self_id) do
    Api.start_typing(msg.channel_id)

    input_prompt =
      message_content_filter(msg.content, self_id)

    # messages is ordered newest-to-oldest
    {:ok, messages} = Api.get_channel_messages(msg.channel_id, 20)

    messages
    |> Enum.map(fn msg ->
      {if msg.author.id == self_id do
         :self
       else
         msg.author.username
       end, message_content_filter(msg.content, self_id)}
    end)
    |> Enum.reverse()
    |> then(&Linguex.DefaultPipeline.submit/1)
    |> then(&Api.create_message!(msg.channel_id, &1))
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
