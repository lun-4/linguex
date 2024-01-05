defmodule Linguex.LLMImpl do
  alias Linguex.LLM.HTTP
  require Logger

  @behaviour Linguex.LLMBehaviour

  defp config do
    Application.fetch_env!(:linguex, Linguex.LLM)
  end

  @impl true
  @spec complete!(String.t(), Keyword.t()) :: String.t()
  def complete!(input_string, opts \\ []) do
    Logger.debug("input to llm #{input_string}")
    Logger.debug("opts: #{inspect(opts)}")

    env =
      HTTP.generate!("#{config()[:url]}", %{
        prompt: input_string,
        max_new_tokens: opts |> Keyword.get(:max_new_tokens, 256),
        stopping_strings: opts |> Keyword.get(:stopping_strings, [])
      })
      |> dbg

    env.body["results"] |> Enum.at(0) |> then(fn entity -> entity["text"] end)
  end

  @impl true
  def embed!(input_string, opts \\ []) do
    env =
      HTTP.embeddings!("#{config()[:url]}", %{
        input: input_string
      })

    env.body["data"] |> Enum.at(0) |> then(fn entity -> entity["embedding"] end)
  end
end
