defmodule Manuscript.Lilypond do
  alias Manuscript.Instrument
  {lilypond_version, 0} = System.cmd("lilypond", ["--version"])

  [[version] | _] = Regex.scan(~r/[\d\.]+/, lilypond_version)
  @lilypond_version version

  @priv :code.priv_dir(:manuscript)
  File.mkdir_p(@priv)

  def generate_lilypond(staves) do
    content = write_lilypond(staves)

    path = Path.join(@priv, "score-for-png")
    ly = path <> ".ly"
    png = path <> ".png"
    :ok = File.write(ly, content)
    {"", 0} = System.cmd("lilypond", ["-s", "--png", "--o", path, ly])
    {:ok, image_data} = File.read(png)
    data = "data:image/png;base64,#{Base.encode64(image_data)}"
    :ok = File.rm(png)
    data
  end

  def generate_pdf_data(staves) do
    content = write_lilypond(staves)

    path = Path.join(@priv, "score-for-pdf")
    ly = path <> ".ly"
    pdf = path <> ".pdf"

    :ok = File.write(ly, content)
    {"", 0} = System.cmd("lilypond", ["-s", "--o", path, ly])
    {:ok, pdf_data} = File.read(pdf)
    data = "data:application/pdf;base64,#{Base.encode64(pdf_data)}"
    :ok = File.rm(pdf)
    data
  end

  def write_lilypond(staves) do
    File.read!(Path.join(:code.priv_dir(:manuscript), "lilypond/score_template.ly"))
    |> String.replace("__LILYPOND_VERSION__", @lilypond_version)
    |> String.replace("__GROUPS__", staff_groups(staves))
  end

  defp staff_groups(staves) do
    staff_count = staves |> Enum.map(&Instrument.Template.staff_count(&1.template)) |> Enum.sum()

    measures =
      case staff_count do
        n when n < 4 -> "s1 \\break s1 \\break s1 \\break s1"
        n when n < 6 -> "s1 \\break s1 \\break s1"
        n when n < 9 -> "s1 \\break s1"
        _ -> "s1"
      end

    Enum.chunk_by(staves, & &1.template.family)
    |> Enum.map_join("\n", fn family ->
      case family do
        [] ->
          ""

        instruments ->
          """
          \\new StaffGroup <<
            #{Enum.map_join(instruments, "\n", &Instrument.staff(&1, measures))}
          >>
          """
      end
    end)
  end
end
