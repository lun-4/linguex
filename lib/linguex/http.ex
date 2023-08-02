defmodule Linguex.LLM.HTTP do
  use Tesla

  require Logger

  # plug(Tesla.Middleware.Headers, [
  # ])

  plug(Tesla.Middleware.JSON, decode_content_types: ["application/json"])

  def generate!(url, data),
    do: post!(url <> "/api/v1/generate", data)

  def info!(url, data),
    do: post!(url <> "/api/v1/model", %{action: "info"})
end
