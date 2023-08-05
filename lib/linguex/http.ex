defmodule Linguex.LLM.HTTP do
  use Tesla

  require Logger

  # plug(Tesla.Middleware.Headers, [
  # ])

  plug(Tesla.Middleware.Timeout, timeout: 15_000)
  plug(Tesla.Middleware.JSON, decode_content_types: ["application/json"])
  adapter(Tesla.Adapter.Hackney, recv_timeout: 30_000)

  def generate!(url, data),
    do: post!(url <> "/api/v1/generate", data)

  def info!(url, data),
    do: post!(url <> "/api/v1/model", %{action: "info"})
end
