defmodule Linguex.LLM do
  alias Linguex.LLM.HTTP
  require Logger

  @spec complete!(String.t()) :: String.t()
  def complete!(input_string, max_new_tokens \\ 256) do
    Logger.debug("input to llm #{input_string}")

    env =
      HTTP.generate!("http://100.101.194.71:5000", %{
        prompt: input_string,
        max_new_tokens: max_new_tokens
      })
      |> IO.inspect()

    env.body
  end
end
