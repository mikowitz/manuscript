defmodule Manuscript.Score.Instrument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "instruments" do
    field :index, :integer
    field :name, :string
    field :family, :string
    field :default_clef, :string

    timestamps(type: :utc_datetime)
  end

  def staff_count(%__MODULE__{default_clef: "piano"}), do: 2
  def staff_count(%__MODULE__{}), do: 1

  @doc false
  def changeset(instrument, attrs) do
    instrument
    |> cast(attrs, [:name, :default_clef, :family, :index])
    |> validate_required([:name, :default_clef, :family, :index])
  end
end
