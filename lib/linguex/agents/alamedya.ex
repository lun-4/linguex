defmodule Linguex.Agents.Alamedya do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def single_discord_message(agent, msg) do
    GenServer.call(agent, {:single_discord_message, msg}, 30000)
  end

  def wipe_history(agent, key) do
    GenServer.call(agent, {:wipe_history, key})
  end

  def simple_client_worker(agent, input, reply_to) do
    reply = single_discord_message(agent, input)
    send(reply_to, reply)
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
           |> Keyword.put(
             :extra,
             "Answer the following questions as best you can. You have access to the following tools:

wikipedia: a search engine for wikipedia articles. useful for when you need to answer questions about current events. input should be a search query.
calculator: useful for getting the result of a math expression. The input to this tool should be a valid mathematical expression that could be executed by a simple calculator.

Use the following format:

Thought: you should always think about what to do
Action: the action to take, should be one of [wikipedia, calculator]
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question

Example:

Action: wikipedia
Action Input: ActivityPub
"
           )
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
    entry = {msg["author"], msg["content"]}

    history =
      state.histories
      |> Map.get(msg["channel_id"], [])
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
       |> Map.put(msg["channel_id"], [{:self, reply} | history])
     )}
  end

  @impl true
  def handle_call({:single_discord_message_react, msg}, _from, state) do
    entry = {msg["author"], msg["content"]}

    history =
      state.histories
      |> Map.get(msg["channel_id"], [])
      |> then(fn history ->
        [entry | history]
      end)

    reply = run_react(history, state)

    {:reply, reply,
     state
     |> Map.put(
       :histories,
       state.histories
       |> Map.put(msg["channel_id"], [{:self, reply} | history])
     )}
  end

  @action_regex ~r/^Action: (.+)$/m
  @action_input_regex ~r/^Action Input: (.*)$/m

  defp run_react(history, state, react_state \\ %{retries: 0}) do
    if react_state.retries > 10 do
      raise "TODO blew max_retries in react loop"
    end

    reply =
      history
      |> to_llm_input(state.react_system_prompt)
      |> Linguex.LLM.complete!(stopping_strings: ["Observation:"])
      |> String.trim()

    Logger.debug("reply: #{inspect(reply)}")

    actions =
      @action_regex
      |> Regex.scan(reply)
      |> then(fn
        [] ->
          reply
          |> String.trim("Final Answer: ")

        [action | _] ->
          [_, action_name] = action

          action_input =
            @action_input_regex
            |> Regex.scan(reply)
            |> Enum.at(0)
            |> then(fn [_, value] -> value end)

          observation = do_action(action_name |> String.downcase(), action_input)

          run_react(
            [
              "Action: #{action_name}\nAction Input: #{action_input}\nObservation: #{observation}"
              | history
            ],
            state,
            react_state
            |> Map.put(:retries, react_state.retries + 1)
          )
      end)
  end

  defp do_action("wikipedia", query) do
    Logger.info("query wikipedia #{inspect(query)}")

    Tesla.get!("https://en.wikipedia.org/w/api.php",
      query: [
        action: "query",
        list: "search",
        srsearch: query,
        format: "json"
      ]
    )
    |> then(fn env -> Jason.decode!(env.body) end)
    |> then(fn data ->
      data["query"]["search"]
      |> Enum.at(0)
      |> then(fn d -> d["snippet"] end)
      # cursed
      |> String.replace("<span class=\"searchmatch\">", "")
      |> String.replace("</span>", "")
    end)
  end

  defp do_action("calculator", data) do
    {:ok, result} = Abacus.eval(data)
    "#{result}"
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
