import Config


if config_env() == :prod do
  config :linguex, Linguex.Repo, database: "./linguex.db"
end
