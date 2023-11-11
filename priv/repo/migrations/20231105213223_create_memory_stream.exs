defmodule Linguex.Repo.Migrations.CreateMemoryStream do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS vector", "DROP EXTENSION vector")

    create table(:memory_stream, primary_key: false) do
      add(:agent, :string, primary_key: true)
      add(:id, :integer, primary_key: true)
      add(:data, :string)
      add(:embedding, :vector, size: 768)
    end
  end
end
