defmodule Linguex.Repo do
  use Ecto.Repo,
    otp_app: :linguex,
    adapter: Ecto.Adapters.SQLite3,

    # sqlite does not do multi-writer. pool_size is effectively one,
    # if it's larger than one, then Database Busy errors haunt you
    pool_size: 1,
    loggers: [Ecto.LogEntry]
end
