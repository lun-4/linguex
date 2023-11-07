defmodule Linguex.LLMBehaviour do
  @callback complete!(String.t(), Keyword.t()) :: String.t()
  @callback embed!(binary()) :: [number()]
end
