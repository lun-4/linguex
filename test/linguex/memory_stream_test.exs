defmodule LinguexWeb.MemoryStreamTest do
  use Linguex.DataCase, async: false

  test "it works somehow" do
    memory =
      Linguex.Repo.insert!(%Linguex.MemoryStream{
        agent: "alamedya",
        id: 1,
        data: "hello world"
      })

    Linguex.Repo.insert!(%Linguex.MemoryStream.Vectors{
      rowid: memory.rowid,
      data_embedding: "[1,2,3]"
    })
  end
end
