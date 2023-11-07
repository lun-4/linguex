defmodule Linguex.Test.DataGenerator do
  def an_embedding, do: 1..768 |> Enum.map(fn _ -> :rand.uniform() end)

  def an_embedding_from(embedding),
    do:
      embedding
      |> Enum.map(fn value ->
        offset = [0.05, -0.05] |> Enum.random()
        value + offset
      end)
end
