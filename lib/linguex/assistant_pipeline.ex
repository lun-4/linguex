defmodule Linguex.Assistant do
  # use Linguex.Pipeline

  def submit(content) do
    character_params = Application.fetch_env!(:linguex, Linguex.Assistant)

    %{results: []}
    |> Linguex.Lug.Character.call(character_params)
    |> render(content)
  end

  def render(prompt, content) do
    final_prompt =
      prompt
      |> Enum.map(fn result ->
        case result do
          %Linguex.Lug.Character.Result{} ->
            Linguex.Lug.Character.render(result)
        end
      end)
      |> Enum.reduce(fn x, acc -> acc <> x end)

    final_prompt ++ [content]
  end
end
