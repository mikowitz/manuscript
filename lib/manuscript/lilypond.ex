defmodule Manuscript.Lilypond do
  alias Manuscript.Score
  alias Manuscript.Score.Instrument

  @lilypond_version Application.compile_env(:manuscript, :lilypond_version, "0.0.0")
  @priv :code.priv_dir(:manuscript)
  File.mkdir_p(@priv)

  def generate_png_data(staves) do
    generate_data(staves, "png", "image/png")
  end

  def generate_pdf_data(staves) do
    generate_data(staves, "pdf", "application/pdf")
  end

  def generate_data(staves, format, mime_type) do
    File.mkdir_p(@priv)
    content = write_lilypond(staves)

    path = Path.join(@priv, "score-for-#{format}")
    ly = path <> ".ly"
    output = path <> ".#{format}"

    :ok = File.write(ly, content)
    {"", 0} = System.cmd("lilypond", ["-s", "--#{format}", "--o", path, ly])
    {:ok, data} = File.read(output)
    data = "data:#{mime_type};base64,#{Base.encode64(data)}"
    :ok = File.rm(output)
    :ok = File.rm(ly)
    data
  end

  def write_lilypond(staves) do
    File.read!(Path.join(:code.priv_dir(:manuscript), "lilypond/score_template.ly"))
    |> String.replace("__LILYPOND_VERSION__", @lilypond_version)
    |> String.replace("__GROUPS__", staff_groups(staves))
  end

  defp staff_groups(staves) do
    Score.to_lilypond(staves)
  end
end
