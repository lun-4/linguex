defmodule Linguex.Assistant do
  # use Linguex.Pipeline

  def submit(content, params) do
    %{results: []}
    |> Linguex.Lug.Character.call(params)
    |> render(content)
    |> process()
  end

  def callback(response) do
    response
  end

  defp process(output) do
    character_result =
      output
      |> Enum.filter(fn {creator, _, _} -> creator == Linguex.Lug.Character end)
      |> Enum.map(fn {_, res, _} -> res end)
      |> Enum.at(0)

    output
    |> Enum.map(fn {creator, _, data} ->
      case creator do
        :prompt -> "User: #{data}"
        :line -> "#{data}"
        :completion_receiver -> "#{character_result.name}: "
        _ -> data
      end
    end)
    |> Enum.reduce(fn x, acc -> acc <> "\n" <> x end)
  end

  def render(output, content) when is_bitstring(content) do
    final_prompt =
      output
      |> Map.get(:results)
      |> Enum.map(fn result ->
        case result do
          %Linguex.Lug.Character.Result{} ->
            {Linguex.Lug.Character, result, Linguex.Lug.Character.render(result)}
        end
      end)

    final_prompt ++ [{:raw, nil, "User: #{content}"}, {:completion_receiver, nil, nil}]
  end

  def render(output, content) when is_list(content) do
    final_prompt =
      output
      |> Map.get(:results)
      |> Enum.map(fn result ->
        case result do
          %Linguex.Lug.Character.Result{} ->
            {Linguex.Lug.Character, result, Linguex.Lug.Character.render(result)}
        end
      end)

    rendered_content =
      content
      |> Enum.map(fn {author, data} -> {:line, nil, "#{author}: #{data}"} end)

    final_prompt ++
      rendered_content ++
      [{:completion_receiver, nil, nil}]
  end
end
