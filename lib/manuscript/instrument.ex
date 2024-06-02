defmodule Manuscript.Instrument do
  defstruct [:name, :clef, :id, :family, :index]

  def new(name) do
    %__MODULE__{name: name, clef: clef(name), id: UUID.uuid4()}
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
end
