defmodule Linguex.Repo.Migrations.CreateMemoryStream do
  use Ecto.Migration

  def change do
    create table(:memory_stream, primary_key: false) do
      add(:agent, :string, primary_key: true)
      add(:id, :integer, primary_key: true)
      add(:data, :string)
    end

    execute(
      """
      create virtual table vss_memory_stream using vss0(
        data_embedding(768)
      );
      """,
      """
      drop table vss_memory_stream
      """
    )
  end
end
