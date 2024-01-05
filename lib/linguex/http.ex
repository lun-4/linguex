defmodule Linguex.LLM.HTTP do
  use Tesla

  require Logger

  # plug(Tesla.Middleware.Headers, [
  # ])

  plug(Tesla.Middleware.Timeout, timeout: 30_000)
  plug(Tesla.Middleware.JSON, decode_content_types: ["application/json"])
  adapter(Tesla.Adapter.Hackney, recv_timeout: 30_000)

  # lol
  if Mix.env() != :test do
    adapter(Tesla.Adapter.Hackney, recv_timeout: 30_000)
  end

  def generate!(url, data),
    do: post!(url <> "/api/v1/generate", data, opts: [adapter: [recv_timeout: 30000]])

  def complete!(url, data),
    do: post!(url <> "/v1/completions", data, opts: [adapter: [recv_timeout: 30000]])

  def embeddings!(url, data),
    do: post!(url <> "/v1/embeddings", data)

  def info!(url),
    do: post!(url <> "/api/v1/model", %{action: "info"})
end
