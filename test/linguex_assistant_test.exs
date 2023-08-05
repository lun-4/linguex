defmodule LinguexAssistantTest do
  use ExUnit.Case

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
Red: "
  end

  test "renders a conversation with multiple users", %{submit: submit} do
    final_prompt =
      submit.([
        {"lun-4", "Amongus"},
        {:self, "awoo"},
        {"Hatsune Miku", "sus"}
      ])

    assert final_prompt ==
             "Red uses he/him pronouns.
Red is an impostor in the hit game Among Us.
Red has the shape of an impostor from the hit game Among Us.
lun-4: Amongus
Red: awoo
Hatsune Miku: sus
Red: "
  end
end
