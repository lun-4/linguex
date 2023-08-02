import Config

config :nostrum,
  gateway_intents: :all

config :nosedrum,
  prefix: "!"

config :linguex, Linguex.Defaults, pipeline: Linguex.Assistant

config :linguex, Linguex.Assistant,
  name: "Alaymeda",
  pronouns: :it_its,
  personality:
    "{name} is an artificial intelligence assistant. {they_are} helpful and courageous.",
  physiology: "{name} has white hair and black eyes."

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
