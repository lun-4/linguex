import Config

if config_env() == :prod or config_env() == :dev do
  discord_token =
    System.get_env("DISCORD_TOKEN") ||
      raise "DISCORD_TOKEN must be set"

  config :nostrum,
    token: discord_token
end
