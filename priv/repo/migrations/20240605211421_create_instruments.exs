defmodule Manuscript.Repo.Migrations.CreateInstruments do
  use Ecto.Migration

  def change do
    create table(:instruments) do
      add :name, :string
      add :default_clef, :string
      add :family, :string
      add :index, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
