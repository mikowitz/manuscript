defmodule Manuscript.Instrument do
  defstruct [:template, :id]

  def new(template) do
    %__MODULE__{template: template, id: UUID.uuid4()}
  end

  def staff(instrument, measures \\ "s1")

  def staff(%__MODULE__{template: %{name: name, clef: "piano"}}, measures) do
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
    } { \\clef "#{template.clef}" #{measures} }
    """
  end

  def matching(text) do
    query = String.replace(text, ~r/[\W\S]/, "")

    Enum.filter(__MODULE__.Template.all(), fn inst ->
      String.match?(inst, ~r/#{query}/i)
    end)
  end
end
