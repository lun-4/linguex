defmodule LinguexWeb.AgentController do
  use LinguexWeb, :controller

  def list(conn, _params) do
    IO.puts("asdj")

    conn
    |> json(%{agents: ["alamedya"]})
  end

  def input(conn, _params) do
    IO.puts("udigue")

    conn
    |> json(%{reply: "alksfjlsakdhg"})
  end
end
