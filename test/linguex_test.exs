defmodule LinguexTest do
  use ExUnit.Case
  doctest Linguex

  test "greets the world" do
    assert Linguex.hello() == :world
  end

  alias Linguex.Lug.Character

  test "renders a character" do
    %{results: [result]} =
      Character.call(%{results: []},
        name: "Amongus",
        pronouns: :it_its,
        personality: "{they_are} sus.",
        physiology: "{they_are} a crewmate."
      )

    assert result.name == "Amongus"

    rendered = Character.render(result)
    assert rendered == "Amongus uses it/its pronouns.\nit is sus.\nit is a crewmate."
  end
end
