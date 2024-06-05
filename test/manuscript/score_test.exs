defmodule Manuscript.ScoreTest do
  use Manuscript.DataCase

  alias Manuscript.Score

  describe "instruments" do
    alias Manuscript.Score.Instrument

    import Manuscript.ScoreFixtures

    @invalid_attrs %{index: nil, name: nil, family: nil, default_clef: nil}

    test "list_instruments/0 returns all instruments" do
      instrument = instrument_fixture()
      assert Score.list_instruments() == [instrument]
    end

    test "get_instrument!/1 returns the instrument with given id" do
      instrument = instrument_fixture()
      assert Score.get_instrument!(instrument.id) == instrument
    end

    test "create_instrument/1 with valid data creates a instrument" do
      valid_attrs = %{index: 42, name: "some name", family: "some family", default_clef: "some default_clef"}

      assert {:ok, %Instrument{} = instrument} = Score.create_instrument(valid_attrs)
      assert instrument.index == 42
      assert instrument.name == "some name"
      assert instrument.family == "some family"
      assert instrument.default_clef == "some default_clef"
    end

    test "create_instrument/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Score.create_instrument(@invalid_attrs)
    end

    test "update_instrument/2 with valid data updates the instrument" do
      instrument = instrument_fixture()
      update_attrs = %{index: 43, name: "some updated name", family: "some updated family", default_clef: "some updated default_clef"}

      assert {:ok, %Instrument{} = instrument} = Score.update_instrument(instrument, update_attrs)
      assert instrument.index == 43
      assert instrument.name == "some updated name"
      assert instrument.family == "some updated family"
      assert instrument.default_clef == "some updated default_clef"
    end

    test "update_instrument/2 with invalid data returns error changeset" do
      instrument = instrument_fixture()
      assert {:error, %Ecto.Changeset{}} = Score.update_instrument(instrument, @invalid_attrs)
      assert instrument == Score.get_instrument!(instrument.id)
    end

    test "delete_instrument/1 deletes the instrument" do
      instrument = instrument_fixture()
      assert {:ok, %Instrument{}} = Score.delete_instrument(instrument)
      assert_raise Ecto.NoResultsError, fn -> Score.get_instrument!(instrument.id) end
    end

    test "change_instrument/1 returns a instrument changeset" do
      instrument = instrument_fixture()
      assert %Ecto.Changeset{} = Score.change_instrument(instrument)
    end
  end
end
