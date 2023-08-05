defmodule LinguexAssistantTest do
  use ExUnit.Case

  import Tesla.Mock

  alias Linguex.Lug.Character

  setup do
    pipeline = Linguex.Assistant

    params = [
      name: "Red",
      pronouns: :he_him,
      personality: "{name} is an impostor in the hit game Among Us.",
      physiology: "{name} has the shape of an impostor from the hit game Among Us."
    ]

    %{
      params: params,
      pipeline: pipeline,
      submit: fn prompt ->
        pipeline.submit(prompt, params)
      end,
      callback: fn prompt ->
        pipeline.callback(prompt)
      end
    }
  end

  test "renders a conversation", %{submit: submit} do
    final_prompt = submit.("Amognus")

    assert final_prompt ==
             "Red uses he/him pronouns.
Red is an impostor in the hit game Among Us.
Red has the shape of an impostor from the hit game Among Us.
User: Amognus
Assistant: "
  end
end
