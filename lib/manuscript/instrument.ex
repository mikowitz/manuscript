defmodule Manuscript.Instrument do
  defstruct [:template, :id]

  def new(template) do
    %__MODULE__{template: template, id: UUID.uuid4()}
  end

  def staff(%__MODULE__{template: %{name: name, clef: "piano"}}) do
    """
    \\new PianoStaff \\with {
      instrumentName = "#{name} "
    } <<
      \\new Staff { \\clef "treble" s1 }
      \\new Staff { \\clef "bass" s1 }
    >>
    """
  end

  def staff(%__MODULE__{template: template}) do
    """
    \\new Staff \\with { instrumentName = "#{template.name} " } { \\clef "#{template.clef}" s1 }
    """
  end

  def matching(text) do
    query = String.replace(text, ~r/[\W\S]/, "")

    Enum.filter(__MODULE__.Template.all(), fn inst ->
      String.match?(inst, ~r/#{query}/i)
    end)
  end
end
