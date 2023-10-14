defmodule Linguex.Agents.Alamedya do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def single_discord_message(agent, msg) do
    GenServer.call(agent, {:single_discord_message_react, msg})
  end

  def wipe_history(agent, key) do
    GenServer.call(agent, {:wipe_history, key})
  end

  defmodule State do
    defstruct [:system_prompt, :react_system_prompt, :histories]
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
       react_system_prompt:
         Linguex.Lug.Character.call(
           @alamedya_character
           |> Keyword.put(:first_instruction, "You are {{name}}")
           |> Keyword.put(:extra, "You run in a loop of Thought, Action, PAUSE, Observation.
At the end of the loop you output an Answer
Use Thought to describe your thoughts about the question you have been asked.
Use Action to run one of the actions available to you - then return PAUSE.
Observation will be the result of running those actions.

Your available actions are:

calculate:
e.g. calculate: 4 * 7 / 3
Runs a calculation and returns the number - uses Python so be sure to use floating point syntax if necessary

wikipedia:
e.g. wikipedia: Django
Returns a summary from searching Wikipedia

Always look things up on Wikipedia if you have the opportunity to do so.

Example session:

Question: What is the capital of France?
Thought: I should look up France on Wikipedia
Action: wikipedia: France
PAUSE

You will be called again with this:

Observation: France is a country. The capital is Paris.

You then output:

Answer: The capital of France is Paris")
         )
         |> Linguex.Lug.Character.render(),
       histories: %{}
     }}
  end

  defp to_llm_input(history, system_prompt) do
    # Nous Hermes style
    "### Instruction:
#{system_prompt}

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
      s when is_bitstring(s) -> s
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
      |> to_llm_input(state.system_prompt)
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
  def handle_call({:single_discord_message_react, msg}, _from, state) do
    entry = {msg.author.username, msg.content}

    history =
      state.histories
      |> Map.get(msg.channel_id, [])
      |> then(fn history ->
        [entry | history]
      end)

    reply = run_react(history, state)

    {:reply, reply,
     state
     |> Map.put(
       :histories,
       state.histories
       |> Map.put(msg.channel_id, [{:self, reply} | history])
     )}
  end

  @action_regex ~r/^Action: (\w+): (.*)$/m

  defp run_react(history, state, react_state \\ %{retries: 0}) do
    if react_state.retries > 10 do
      raise "TODO blew max_retries in react loop"
    end

    reply =
      history
      |> to_llm_input(state.react_system_prompt)
      |> Linguex.LLM.complete!()
      |> String.trim()

    actions =
      @action_regex
      |> Regex.scan(reply)
      |> then(fn
        [] ->
          reply
          |> String.trim("Answer: ")

        [action | _] ->
          [_, action_name, action_argument] = action
          observation = do_action(action_name, action_argument)

          run_react(
            ["Observation: #{observation}" | history],
            react_state
            |> Map.put(:retries, react_state.retries + 1)
          )
      end)
  end

  defp do_action("wikipedia", data) do
    raise "wikipedia #{data}"
  end

  defp do_action("calculate", data) do
    raise "calculate #{data}"
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
