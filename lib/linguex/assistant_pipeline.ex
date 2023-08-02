defmodule Linguex.Assistant do
  # use Linguex.Pipeline

  def submit(content) do
    character_params = Application.fetch_env!(:linguex, Linguex.Assistant)

    %{results: []}
    |> Linguex.Lug.Character.call(character_params)
    |> render(content)
    |> process()
    |> Linguex.LLM.complete!()
  end

  defp process(output) do
    output
    |> Enum.map(fn {_, x} -> x end)
    |> Enum.reduce(fn x, acc -> acc <> x end)
  end

  def render(output, content) do
    final_prompt =
      output
      |> Map.get(:results)
      |> Enum.map(fn result ->
        case result do
          %Linguex.Lug.Character.Result{} ->
            {Linguex.Lug.Character, Linguex.Lug.Character.render(result)}
        end
      end)

    final_prompt ++ [{:prompt, content}]
  end
end
