defmodule Manuscript.Instrument do
  defstruct [:name, :clef, :id, :family, :index]

  def new(name) do
    %__MODULE__{name: name, clef: clef(name), id: UUID.uuid4()}
  end

  def instruments do
    [
      "Accordion",
      "Alto Flute",
      "Alto Saxophone",
      "Alto Trombone",
      "Alto Voice",
      "Baritone Saxophone",
      "Baritone Voice",
      "Bass Clarinet",
      "Bass Flute",
      "Bassoon",
      "Bass Saxophone",
      "Bass Trombone",
      "Bass Voice",
      "Cello",
      "Clarinet In A",
      "Clarinet In B Flat",
      "Clarinet In E Flat",
      "Contrabass",
      "Contrabass Clarinet",
      "Contrabass Flute",
      "Contrabassoon",
      "Contrabass Saxophone",
      "EnglishHorn",
      "Flute",
      "FrenchHorn",
      "Glockenspiel",
      "Guitar",
      "Harp",
      "Harpsichord",
      "Marimba",
      "Mezzo Soprano Voice",
      "Oboe",
      "Percussion",
      "Piano",
      "Piccolo",
      "Sopranino Saxophone",
      "Soprano Saxophone",
      "Soprano Voice",
      "Tenor Saxophone",
      "Tenor Trombone",
      "Tenor Voice",
      "Trumpet",
      "Tuba",
      "Vibraphone",
      "Viola",
      "Violin",
      "Xylophone"
    ]
  end

  def clef("Viola"), do: "alto"
  def clef("Bassoon"), do: "bass"
  def clef("Trombone"), do: "bass"
  def clef("Tuba"), do: "bass"
  def clef("Violoncello"), do: "bass"
  def clef("Double bass"), do: "bass"
  def clef("Percussion"), do: "percussion"
  def clef(_), do: "treble"

  def staff(%__MODULE__{name: "Piano"}) do
    """
    \\new PianoStaff \\with {
      instrumentName = "Piano"
    } <<
      \\new Staff { \\clef "treble" s1 }
      \\new Staff { \\clef "bass" s1 }
    >>
    """
  end

  def staff(instrument) do
    """
    \\new Staff \\with { instrumentName = "#{instrument.name}" } { \\clef "#{instrument.clef}" s1 }
    """
  end

  def matching(text) do
    query = String.replace(text, ~r/[\W\S]/, "")

    Enum.filter(instruments(), fn inst ->
      String.match?(inst, ~r/#{query}/i)
    end)
  end
end
