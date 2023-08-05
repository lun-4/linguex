defmodule LinguexAssistantTest do
  use ExUnit.Case

  import Tesla.Mock

  alias Linguex.Lug.Character

  setup do
    pipeline = Linguex.Assistant

    params = [
      name: "Alaymeda",
      pronouns: :it_its,
      personality:
        "{name} is an artificial intelligence assistant. {they_are} helpful and courageous.",
      physiology: "{name} has white hair and black eyes."
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

    assert final_prompt == "Alaymeda uses it/its pronouns.
Alaymeda is an artificial intelligence assistant. it is helpful and courageous.
Alaymeda has white hair and black eyes.
User: Amognus
Assistant: "
  end
end
