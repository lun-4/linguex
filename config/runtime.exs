import Config

required_env! = fn env_name ->
  System.get_env(env_name) ||
    raise """
    missing #{env_name} env
    """
end

if config_env() == :prod do
  database_host = required_env!.("DATABASE_HOSTNAME")
  database_port = required_env!.("DATABASE_PORT")
  database_name = required_env!.("DATABASE_NAME")
  database_username = required_env!.("DATABASE_USERNAME")
  database_password = required_env!.("DATABASE_PASSWORD")

  config :linguex, Linguex.Repo,
    database: database_name,
    username: database_username,
    password: database_password,
    hostname: database_host,
    port: database_port,
    types: Linguex.PostgrexTypes
end

config :linguex, Linguex.LLM, url: System.get_env("OPENAI_ENDPOINT") || "http://localhost:5001"
