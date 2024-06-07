defmodule Manuscript.Score.Staff do
  defstruct [:instrument, :id, :name, :clef]

  def new(instrument) do
    %__MODULE__{
      instrument: instrument,
      id: UUID.uuid4(),
      name: instrument.name,
      clef: instrument.default_clef
    }
  end

  def clefs, do: ~w(treble alto tenor bass percussion piano)

  def to_lilypond(instrument, measures \\ "s1")

  def to_lilypond(%__MODULE__{name: name, clef: "piano"}, measures) do
    """
    \\new PianoStaff \\with {
      instrumentName = "#{name} "
      shortInstrumentName = "#{name} "
    } <<
      \\new Staff { \\clef "treble" #{measures} }
      \\new Staff { \\clef "bass" #{measures} }
    >>
    """
  end

  def to_lilypond(%__MODULE__{name: name, clef: clef}, measures) do
    """
    \\new Staff \\with {
      instrumentName = "#{name} "
      shortInstrumentName = "#{name} "
    } { \\clef "#{clef}" #{measures} }
    """
  end
end
