defmodule Linguex.Lug.Character do
  def describe do
    {:ok,
     %{
       kind: :primary
     }}
  end

  defmodule Result do
    defstruct [:name, :pronouns, :personality, :physiology, :extra, :first_instruction]
  end

  def call(opts) do
    %Result{
      first_instruction: Keyword.get(opts, :first_instruction),
      name: Keyword.get(opts, :name),
      pronouns: Keyword.get(opts, :pronouns),
      personality: Keyword.get(opts, :personality),
      physiology: Keyword.get(opts, :physiology),
      extra: Keyword.get(opts, :extra)
    }
  end

  @default_pronouns %{
    :he_him => %{
      shorthand: "he/him",
      they: "he",
      they_are: "he is",
      they_re: "he's",
      them: "him",
      theirs: "his"
    },
    :she_her => %{
      shorthand: "she/her",
      they: "she",
      they_are: "she is",
      they_re: "she's",
      them: "her",
      theirs: "hers"
    },
    :it_its => %{
      shorthand: "it/its",
      they: "it",
      they_are: "it is",
      they_re: "it's",
      them: "it",
      theirs: "its"
    }
  }

  defp render_any_text(result, input_text) do
    pronoun_keys =
      case result.pronouns do
        pronouns when is_map(pronouns) ->
          pronouns

        pronouns when is_atom(pronouns) ->
          @default_pronouns[result.pronouns]

        _ ->
          raise "invalid pronouns #{inspect(result.pronouns)}"
      end

    unless input_text == nil do
      input_text
      |> String.replace("{name}", result.name)
      |> String.replace("{they_are}", pronoun_keys.they_are)
      |> String.replace("{they_re}", pronoun_keys.they_re)
      |> String.replace("{pronoun_shorthand}", pronoun_keys.shorthand)
    else
      nil
    end
  end

  defp _maybe(text) do
    unless text == nil do
      "\n#{text}"
    else
      ""
    end
  end

  def render(result) do
    with personality <- render_any_text(result, result.personality),
         first_instruction <- render_any_text(result, result.first_instruction),
         physiology <- render_any_text(result, result.physiology),
         extra <- render_any_text(result, result.extra) do
      character = render_any_text(result, "{name} uses {pronoun_shorthand} pronouns.")

      "#{_maybe(first_instruction)}#{_maybe(character)}#{_maybe(personality)}#{_maybe(physiology)}#{_maybe(extra)}"
    end
  end
end
