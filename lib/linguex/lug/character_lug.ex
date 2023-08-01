defmodule Lug.Builtin.CharacterLug do
  # import Lug.Result

  def init(opts) do
    {:ok,
     %{
       doc: "This is a lug that assembles a character with common humanesque protocols.",
       result_type: CharacterResult
     }, opts}
  end

  defmodule CharacterResult do
    @enforce_keys [:name, :pronouns, :physiological_description]

    defstruct [:name, :pronouns, :physiological_description]
  end

  def call(results, args) do
    {results,
     %CharacterResult{
       name: args.name,
       pronouns: args.pronouns,
       physiological_description: args.physiological_description
     }}
  end

  def render(result) do
    "#{result.name}, using pronouns #{result.pronouns}, is #{result.physiological_description}"
  end
end
