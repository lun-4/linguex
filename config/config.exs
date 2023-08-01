import Config

config :nostrum,
  gateway_intents: :all

config :nosedrum,
  prefix: "!"

config :linguex,
  default_pipeline: Linguex.Assistant

config :linguex, Linguex.Assistant,
  name: "Alaymeda",
  pronouns: :it_its,
  personality: "{name} is an artificial intelligence assistant. {they_are} helpful and courageous.",
  physiology: "{name} has white hair and black eyes."

import_config "#{Mix.env()}.exs"
