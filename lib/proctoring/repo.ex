defmodule Proctoring.Repo do
  use Ecto.Repo,
    otp_app: :proctoring,
    adapter: Ecto.Adapters.Postgres
end
