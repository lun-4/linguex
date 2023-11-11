import Config

config :linguex,
  ecto_repos: [Linguex.Repo]

config :nostrum,
  gateway_intents: :all

config :nosedrum,
  prefix: "!"

config :linguex, LinguexWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: LinguexWeb.ErrorJSON],
    layout: false
  ],
  live_view: [signing_salt: "7p7hMPr9"]

config :linguex, Linguex.Repo,
  database: "linguex_#{Mix.env()}",
  username: "linguex",
  password: "123456",
  hostname: "localhost",
  types: Linguex.PostgrexTypes

config :linguex, Linguex.Defaults, pipeline: Linguex.Assistant

config :linguex, Linguex.Assistant,
  name: "Alaymeda",
  pronouns: :it_its,
  personality:
    "{name} is an artificial intelligence assistant. {they_are} helpful and courageous.",
  physiology: "{name} has white hair and black eyes."

config :tesla, adapter: Tesla.Adapter.Hackney

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
