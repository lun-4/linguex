defmodule LinguexWeb.AgentController do
  use LinguexWeb, :controller

  def list(conn, _params) do
    IO.puts("asdj")

    conn
    |> json(%{agents: ["alamedya"]})
  end

  def input(conn, %{"input_data" => input_data}) do
    reply =
      input_data
      |> then(&Linguex.Agents.Alamedya.single_discord_message(Linguex.Agents.Alamedya, &1))

    conn
    |> json(%{reply: reply})
  end
end
