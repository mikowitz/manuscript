defmodule Manuscript.Repo do
  use Ecto.Repo,
    otp_app: :manuscript,
    adapter: Ecto.Adapters.Postgres
end
