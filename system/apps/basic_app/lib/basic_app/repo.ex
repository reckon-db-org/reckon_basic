defmodule BasicApp.Repo do
  use Ecto.Repo,
    otp_app: :basic_app,
    adapter: Ecto.Adapters.Postgres
end
