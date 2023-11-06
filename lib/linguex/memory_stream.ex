defmodule Linguex.MemoryStream do
  use Ecto.Schema
  import Ecto.Query
  alias Linguex.Repo

  @primary_key false

  schema "memory_stream" do
    field(:rowid, :integer)
    field(:agent, :string)
    field(:id, :integer)
    field(:data, :string)
  end

  defmodule Vectors do
    use Ecto.Schema
    @primary_key false
    schema "vss_memory_stream" do
      field(:rowid, :integer)
      field(:data_embedding, :string)
    end
  end

  def insert!(agent, id, data) do
    Repo.transaction(fn repo ->
      memory =
        %__MODULE__{agent: agent, id: id, data: data}
        |> repo.insert!()

      memory =
        from(m in __MODULE__,
          select: m,
          where:
            m.agent == ^agent and
              m.id ==
                ^id
        )
        |> repo.one

      embedding = Linguex.LLM.embed!(data) |> Jason.encode!()

      repo.query!(
        """
        insert into vss_memory_stream (rowid, data_embedding)
        values ($1, $2)
        """,
        [memory.rowid, embedding]
      )

      memory_vector = %__MODULE__.Vectors{
        rowid: memory.rowid,
        data_embedding: embedding
      }

      {memory, memory_vector}
    end)
  end

  def alike(agent, text) do
    Repo.query!(
      """
      select rowid, distance
      from vss_memory_stream
      where vss_search(
        data_embedding,
        $1
      )
      limit 100;
      """,
      [Linguex.LLM.embed!(text) |> Jason.encode!()]
    )
  end
end
