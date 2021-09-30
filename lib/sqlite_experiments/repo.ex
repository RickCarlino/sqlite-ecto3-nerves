defmodule SqliteExperiments.Repo do
  use Ecto.Repo,
    otp_app: :sqlite_experiments,
    adapter: Ecto.Adapters.SQLite3
end
