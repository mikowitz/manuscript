defmodule Manuscript.Score do
  @moduledoc """
  The Score context.
  """

  import Ecto.Query, warn: false
  alias Manuscript.Score.Staff
  alias Manuscript.Repo

  alias Manuscript.Score.Instrument

  ## PRAGMA: instruments

  @doc """
  Returns the list of instruments.

  ## Examples

      iex> list_instruments()
      [%Instrument{}, ...]

  """
  def list_instruments do
    Repo.all(Instrument)
  end

  @doc """
  Returns a list of instruments matching the query.
  """
  def instruments_matching(query) do
    query = from i in Instrument, where: ilike(i.name, ^"%#{query}%")
    Repo.all(query)
  end

  @doc """
  Gets a single instrument.

  Raises `Ecto.NoResultsError` if the Instrument does not exist.

  ## Examples

      iex> get_instrument!(123)
      %Instrument{}

      iex> get_instrument!(456)
      ** (Ecto.NoResultsError)

  """
  def get_instrument!(id), do: Repo.get!(Instrument, id)

  def instrument_by_name(name) do
    query =
      from i in Instrument,
        where: i.name == ^"#{name}"

    Repo.one(query)
  end

  @doc """
  Creates a instrument.

  ## Examples

      iex> create_instrument(%{field: value})
      {:ok, %Instrument{}}

      iex> create_instrument(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_instrument(attrs \\ %{}) do
    %Instrument{}
    |> Instrument.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a instrument.

  ## Examples

      iex> update_instrument(instrument, %{field: new_value})
      {:ok, %Instrument{}}

      iex> update_instrument(instrument, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_instrument(%Instrument{} = instrument, attrs) do
    instrument
    |> Instrument.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a instrument.

  ## Examples

      iex> delete_instrument(instrument)
      {:ok, %Instrument{}}

      iex> delete_instrument(instrument)
      {:error, %Ecto.Changeset{}}

  """
  def delete_instrument(%Instrument{} = instrument) do
    Repo.delete(instrument)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking instrument changes.

  ## Examples

      iex> change_instrument(instrument)
      %Ecto.Changeset{data: %Instrument{}}

  """
  def change_instrument(%Instrument{} = instrument, attrs \\ %{}) do
    Instrument.changeset(instrument, attrs)
  end

  ## PRAGMA: score

  def to_lilypond(staves) do
    staff_count =
      staves |> Enum.map(&Instrument.staff_count(&1.instrument)) |> Enum.sum()

    measures =
      case staff_count do
        n when n <= 2 -> "s1 \\break s1 \\break s1 \\break s1 \\break s1"
        n when n <= 4 -> "s1 \\break s1 \\break s1 \\break s1"
        n when n <= 5 -> "s1 \\break s1 \\break s1"
        n when n <= 9 -> "s1 \\break s1"
        _ -> "s1"
      end

    Enum.chunk_by(staves, & &1.instrument.family)
    |> Enum.map_join("\n", fn family ->
      case family do
        [] ->
          ""

        instruments ->
          """
          \\new StaffGroup <<
            #{Enum.map_join(instruments, "\n", &Staff.to_lilypond(&1, measures))}
          >>
          """
      end
    end)
  end
end
