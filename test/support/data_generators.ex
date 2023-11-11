defmodule Linguex.Test.DataGenerator do
  def an_embedding, do: 1..768 |> Enum.map(fn _ -> :rand.uniform() end)

  def an_embedding_from(embedding),
    do:
      embedding
      |> Enum.map(fn value ->
        # more realistic embedding changes
        magnitude_offset = 1..2 |> Enum.random() |> then(fn x -> :math.pow(10, -x) end)
        value_offset = 1..3 |> Enum.random()
        sign_offset = [-1, 1] |> Enum.random()
        offset = sign_offset * magnitude_offset * value_offset
        value + offset
      end)
end
