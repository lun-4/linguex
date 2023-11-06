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
  cache_size: -16_000,
  auto_vacuum: :incremental,
  after_connect: fn _conn ->
    # stolen from 
    # https://github.com/mindreframer/sqlite_init#updated-improvement-thanks-to-ruslandoga
    # thanks very much!!!

    [db_conn] = Process.get(:"$callers")
    {_, db_connection_state} = :sys.get_state(db_conn)
    conn = db_connection_state.state
    IO.inspect(conn, label: "conn")
    :ok = Exqlite.Basic.enable_load_extension(conn)

    Exqlite.Basic.load_extension(conn, SqliteVss.loadable_path_vector0())
    Exqlite.Basic.load_extension(conn, SqliteVss.loadable_path_vss0())
  end

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
