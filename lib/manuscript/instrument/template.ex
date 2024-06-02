defmodule Manuscript.Instrument.Template do
  defstruct [:name, :clef, :family, :index]

  def by_name(name), do: Enum.find(all(), &(&1.name == name))

  def matching(text) do
    query = String.replace(text, ~r/[\W\S]/, "")

    Enum.filter(all(), fn inst ->
      String.match?(inst.name, ~r/#{query}/i)
    end)
  end

  def all do
    [
      # WINDS
      {"Piccolo", "treble", "winds"},
      {"Flute", "treble", "winds"},
      {"Alto Flute", "treble", "winds"},
      {"Bass Flute", "treble", "winds"},
      {"Contrabass Flute", "treble", "winds"},
      {"Oboe", "treble", "winds"},
      {"English Horn", "treble", "winds"},
      {"Clarinet In E Flat", "treble", "winds"},
      {"Clarinet In A", "treble", "winds"},
      {"Clarinet In B Flat", "treble", "winds"},
      {"Bass Clarinet", "treble", "winds"},
      {"Contrabass Clarinet", "treble", "winds"},
      {"Sopranino Saxophone", "treble", "winds"},
      {"Soprano Saxophone", "treble", "winds"},
      {"Alto Saxophone", "treble", "winds"},
      {"Tenor Saxophone", "treble", "winds"},
      {"Baritone Saxophone", "treble", "winds"},
      {"Bass Saxophone", "treble", "winds"},
      {"Contrabass Saxophone", "treble", "winds"},
      {"Bassoon", "bass", "winds"},
      {"Contrabassoon", "bass", "winds"},

      # BRASS
      {"Trumpet", "treble", "brass"},
      {"French Horn", "treble", "brass"},
      {"Alto Trombone", "bass", "brass"},
      {"Tenor Trombone", "bass", "brass"},
      {"Bass Trombone", "bass", "brass"},
      {"Tuba", "bass", "brass"},

      # PERCUSSION
      {"Timpani", "bass", "percussion"},
      {"Percussion", "percussion", "percussion"},

      # KEYBOARD
      {"Accordion", "piano", "keyboard"},
      {"Glockenspiel", "treble", "keyboard"},
      {"Harpsichord", "piano", "keyboard"},
      {"Marimba", "treble", "keyboard"},
      {"Piano", "piano", "keyboard"},
      {"Vibraphone", "treble", "keyboard"},
      {"Xylophone", "treble", "keyboard"},

      # CHORAL
      {"Soprano Voice", "treble", "choral"},
      {"Mezzo Soprano Voice", "treble", "choral"},
      {"Alto Voice", "treble", "choral"},
      {"Tenor Voice", "treble", "choral"},
      {"Baritone Voice", "bass", "choral"},
      {"Bass Voice", "bass", "chordal"},

      # PLUCKED
      {"Harp", "piano", "plucked"},
      {"Guitar", "treble", "plucked"},

      # STRINGS
      {"Violin", "treble", "strings"},
      {"Viola", "alto", "strings"},
      {"Cello", "bass", "strings"},
      {"Contrabass", "bass", "strings"}
    ]
    |> Enum.with_index()
    |> Enum.map(fn {{name, clef, family}, index} ->
      %__MODULE__{name: name, clef: clef, family: family, index: index}
    end)
  end
end

