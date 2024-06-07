defmodule Manuscript.Score.Staff do
  defstruct [:instrument, :id]

  def new(instrument) do
    %__MODULE__{instrument: instrument, id: UUID.uuid4()}
  end

  def to_lilypond(instrument, measures \\ "s1")

  def to_lilypond(%__MODULE__{instrument: %{name: name, default_clef: "piano"}}, measures) do
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

  def to_lilypond(%__MODULE__{instrument: instrument}, measures) do
    """
    \\new Staff \\with {
      instrumentName = "#{instrument.name} "
      shortInstrumentName = "#{instrument.name} "
    } { \\clef "#{instrument.default_clef}" #{measures} }
    """
  end
end
