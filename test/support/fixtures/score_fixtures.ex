defmodule Manuscript.ScoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Manuscript.Score` context.
  """

  @doc """
  Generate a instrument.
  """
  def instrument_fixture(attrs \\ %{}) do
    {:ok, instrument} =
      attrs
      |> Enum.into(%{
        default_clef: "some default_clef",
        family: "some family",
        index: 42,
        name: "some name"
      })
      |> Manuscript.Score.create_instrument()

    instrument
  end
end
