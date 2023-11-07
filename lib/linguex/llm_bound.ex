defmodule Linguex.LLMBound do
  def complete!(input_string, opts \\ []) do
    llm_impl().complete!(input_string, opts)
  end

  def embed!(input_string) do
    llm_impl().embed!(input_string)
  end

  defp llm_impl() do
    Application.get_env(:bound, :llm, Linguex.LLMImpl)
  end
end
