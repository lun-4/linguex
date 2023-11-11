defmodule Linguex.MemoryStream do
  use Ecto.Schema
  import Ecto.Query
  import Pgvector.Ecto.Query
  alias Linguex.Repo

  @primary_key false

  schema "memory_stream" do
    field(:agent, :string)
    field(:id, :integer)
    field(:data, :string)
    field(:embedding, Pgvector.Ecto.Vector)
  end

  def insert!(agent, id, data) do
    embedding = Linguex.LLMBound.embed!(data)

    %__MODULE__{agent: agent, id: id, data: data, embedding: embedding}
    |> Repo.insert!()
  end

  def alike(agent, text) do
    target_embedding = Linguex.LLMBound.embed!(text)

    Repo.all(
      from(m in __MODULE__,
        where: m.agent == ^agent,
        order_by: l2_distance(m.embedding, ^target_embedding),
        limit: 5
      )
    )
  end
end
