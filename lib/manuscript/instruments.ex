defmodule Manuscript.Instruments do
  def instruments do
    [
      "Accordion",
      "Alto Flute",
      "Alto Saxophone",
      "Alto Trombone",
      "Alto Voice",
      "Baritone Saxophone",
      "Baritone Voice",
      "Bass Clarinet",
      "Bass Flute",
      "Bassoon",
      "Bass Saxophone",
      "Bass Trombone",
      "Bass Voice",
      "Cello",
      "Clarinet In A",
      "Clarinet In B Flat",
      "Clarinet In E Flat",
      "Contrabass",
      "Contrabass Clarinet",
      "Contrabass Flute",
      "Contrabassoon",
      "Contrabass Saxophone",
      "EnglishHorn",
      "Flute",
      "FrenchHorn",
      "Glockenspiel",
      "Guitar",
      "Harp",
      "Harpsichord",
      "Marimba",
      "Mezzo Soprano Voice",
      "Oboe",
      "Percussion",
      "Piano",
      "Piccolo",
      "Sopranino Saxophone",
      "Soprano Saxophone",
      "Soprano Voice",
      "Tenor Saxophone",
      "Tenor Trombone",
      "Tenor Voice",
      "Trumpet",
      "Tuba",
      "Vibraphone",
      "Viola",
      "Violin",
      "Xylophone"
    ]
  end

  def matching(text) do
    query = String.replace(text, ~r/[\W\S]/, "")

    Enum.filter(instruments(), fn inst ->
      String.match?(inst, ~r/#{query}/i)
    end)
  end
end
