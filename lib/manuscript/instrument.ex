defmodule Manuscript.Instrument do
  defstruct [:template, :id]

  def new(template) do
    %__MODULE__{template: template, id: UUID.uuid4()}
  end

  def staff(instrument, measures \\ "s1")

  def staff(%__MODULE__{template: %{name: name, default_clef: "piano"}}, measures) do
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

  def staff(%__MODULE__{template: template}, measures) do
    """
    \\new Staff \\with {
      instrumentName = "#{template.name} "
      shortInstrumentName = "#{template.name} "
    } { \\clef "#{template.default_clef}" #{measures} }
    """
  end
end
