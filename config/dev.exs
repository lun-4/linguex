import Config

config :linguex, LinguexWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "TaKSaRg6sxJHM3t1+rgLCtrkBblqqRldvRSWPa537/zFmr3Rx/VW9qRpyTNPCUZJ",
  watchers: []

config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :linguex, Linguex.Repo,
  database: Path.expand("../linguex_dev.db", Path.dirname(__ENV__.file)),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

if File.exists?("config/dev.secret.exs") do
  import_config "dev.secret.exs"
end
