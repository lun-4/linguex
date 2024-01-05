import Config

config :tesla, adapter: Tesla.Mock

config :linguex, Linguex.Repo,
  queue_target: 10000,
  queue_timeout: 10000,
  pool: Ecto.Adapters.SQL.Sandbox
