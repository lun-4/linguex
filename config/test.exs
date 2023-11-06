import Config

config :nostrum,
  token: "..."

config :nosedrum,
  prefix: "!"

config :tesla, adapter: Tesla.Mock

config :linguex, Linguex.Repo,
  database: Path.expand("../linguex_test.db", Path.dirname(__ENV__.file)),
  pool_size: 1,
  queue_target: 10000,
  queue_timeout: 10000,
  pool: Ecto.Adapters.SQL.Sandbox
