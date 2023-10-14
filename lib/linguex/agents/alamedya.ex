defmodule Linguex.Agents.Alamedya do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def single_discord_message(agent, msg) do
    GenServer.call(agent, {:single_discord_message, msg})
  end

  def wipe_history(agent, key) do
    GenServer.call(agent, {:wipe_history, key})
  end

  defmodule State do
    defstruct [:version, :system_prompt, :histories]
  end

  @alamedya_character [
    name: "Alamedya",
    pronouns: :it_its,
    personality:
      "{name} is an artificial intelligence assistant. {they_are} helpful and courageous.",
    physiology: "{name} has white hair and black eyes.",
    extra:
      "You will receive a series of messages as input, you will reply with a line that starts with \"Alaymeda: \""
  ]

  @impl true
  def init(opts) do
    # TODO this is where we'd add Ecto hooks to fetch history for a given key
    {:ok,
     %State{
       system_prompt:
         Linguex.Lug.Character.call(@alamedya_character)
         |> Linguex.Lug.Character.render(),
       histories: %{}
     }}
  end

  defp to_llm_input(history, state) do
    # Nous Hermes style
    "### Instruction:
#{state.system_prompt}

### Input:
#{history |> render_history}

### Output:
"
  end

  defp render_history(history) do
    history
    |> Enum.reverse()
    |> Enum.map(fn
      {:self, text} -> "Alamedya: #{text}"
      {a, b} -> "#{a}: #{b}"
    end)
    |> Enum.reduce(fn x, acc -> acc <> "\n" <> x end)
  end

  @impl true
  def handle_call({:single_discord_message, msg}, _from, state) do
    entry = {msg.author.username, msg.content}

    history =
      state.histories
      |> Map.get(msg.channel_id, [])
      |> then(fn history ->
        [entry | history]
      end)

    reply =
      history
      |> to_llm_input(state)
      |> Linguex.LLM.complete!()
      |> String.trim()
      |> String.trim("#{@alamedya_character |> Keyword.get(:name)}: ")
      |> String.trim()

    {:reply, reply,
     state
     |> Map.put(
       :histories,
       state.histories
       |> Map.put(msg.channel_id, [{:self, reply} | history])
     )}
  end

  @impl true
  def handle_call({:wipe_history, key}, _from, state) do
    {:reply, :ok,
     state
     |> Map.put(
       :histories,
       state.histories
       |> Map.delete(key)
     )}
  end
end
