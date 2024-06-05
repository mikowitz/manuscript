defmodule Manuscript.Lilypond do
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
    staff_count =
      staves |> Enum.map(&Instrument.staff_count(&1.instrument)) |> Enum.sum()

    measures =
      case staff_count do
        n when n <= 2 -> "s1 \\break s1 \\break s1 \\break s1 \\break s1"
        n when n <= 4 -> "s1 \\break s1 \\break s1 \\break s1"
        n when n <= 5 -> "s1 \\break s1 \\break s1"
        n when n <= 9 -> "s1 \\break s1"
        _ -> "s1"
      end

    Enum.chunk_by(staves, & &1.instrument.family)
    |> Enum.map_join("\n", fn family ->
      case family do
        [] ->
          ""

        instruments ->
          """
          \\new StaffGroup <<
            #{Enum.map_join(instruments, "\n", &Manuscript.Score.Staff.staff(&1, measures))}
          >>
          """
      end
    end)
  end
end
