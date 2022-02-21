defmodule Bubba.Repo do
  use Ecto.Repo,
    otp_app: :bubba,
    adapter: Ecto.Adapters.Postgres
end
