defmodule Manuscript.Lilypond do
  alias Manuscript.Instrument
  {lilypond_version, 0} = System.cmd("lilypond", ["--version"])

  [[version] | _] = Regex.scan(~r/[\d\.]+/, lilypond_version)
  @lilypond_version version

  def generate_lilypond(staves) do
    content = write_lilypond(staves)

    :ok = File.write("priv/score.ly", content)
    {"", 0} = System.cmd("lilypond", ["-s", "--png", "--o", "priv/score", "priv/score.ly"])
    {:ok, image_data} = File.read("priv/score.png")
    data = "data:image/png;base64,#{Base.encode64(image_data)}"
    :ok = File.rm("priv/score.png")
    data
  end

  def generate_pdf_data(staves) do
    content = write_lilypond(staves)

    :ok = File.write("priv/score.ly", content)
    {"", 0} = System.cmd("lilypond", ["-s", "--o", "priv/score", "priv/score.ly"])
    {:ok, pdf_data} = File.read("priv/score.pdf")
    data = "data:application/pdf;base64,#{Base.encode64(pdf_data)}"
    :ok = File.rm("priv/score.pdf")
    data
  end

  def write_lilypond(staves) do
    """
    \\version "#{@lilypond_version}"

    \\paper {
      ragged-right = ##f
      ragged-last-right = ##f
      tagline = ##f
    }

    \\score {
      <<
      #{Enum.map_join(staves, "\n", &Instrument.staff/1)}
      >>
    }

    \\layout {
      \\context {
        \\Score
        \\omit TimeSignature

      }
    }
    """
  end
end

