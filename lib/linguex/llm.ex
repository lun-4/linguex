defmodule Linguex.LLM do
  alias Linguex.LLM.HTTP
  require Logger

  @spec complete!(String.t(), Keyword.t()) :: String.t()
  def complete!(input_string, opts \\ []) do
    Logger.debug("input to llm #{input_string}")
    Logger.debug("opts: #{inspect(opts)}")

    env =
      HTTP.generate!("http://100.101.194.71:5000", %{
        prompt: input_string,
        max_new_tokens: opts |> Keyword.get(:max_new_tokens, 256),
        stopping_strings: opts |> Keyword.get(:stopping_strings, [])
      })
      |> dbg

    env.body["results"] |> Enum.at(0) |> then(fn entity -> entity["text"] end)
  end
end
