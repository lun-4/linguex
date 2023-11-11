defmodule Linguex.Repo do
  use Ecto.Repo,
    otp_app: :linguex,
    adapter: Ecto.Adapters.Postgres,
    loggers: [Ecto.LogEntry]
end
