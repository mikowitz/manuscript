defmodule ManuscriptWeb.ManuscriptLive do
  alias Manuscript.Instrument
  use ManuscriptWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       search_term: "",
       search_results: [],
       instruments: [],
       score: nil,
       pdf_score: nil,
       generating: false
     )}
  end

  def handle_event("autocomplete", %{"instrument" => instrument}, socket) do
    instruments = Manuscript.Instruments.matching(instrument)
    {:noreply, assign(socket, search_results: instruments, search_term: instrument)}
  end

  def handle_event("add_instrument", %{"instrument" => instrument}, socket) do
    if instrument in Manuscript.Instruments.instruments() do
      new_instruments = [Instrument.new(instrument) | socket.assigns.instruments]
      send(self(), {:generate_lilypond, new_instruments})

      {:noreply,
       assign(socket,
         search_term: "",
         search_results: [],
         instruments: new_instruments,
         generating: true
       )}
    else
      {:noreply, assign(socket, search_term: "")}
    end
  end

  def handle_event("delete_instrument", %{"id" => id}, socket) do
    instruments = socket.assigns.instruments |> Enum.reject(fn i -> i.id == id end)
    send(self(), {:generate_lilypond, instruments})

    {:noreply,
     assign(socket,
       search_term: "",
       instruments: instruments,
       generating: instruments != []
     )}
  end

  def handle_info({:generate_lilypond, staves}, socket) do
    score = generate_png(staves)
    pdf_score = generate_pdf(staves)

    {:noreply, assign(socket, score: score, pdf_score: pdf_score, generating: false)}
  end

  def generate_pdf([]), do: nil

  def generate_pdf(staves) do
    Task.async(fn ->
      Manuscript.Lilypond.generate_pdf_data(staves)
    end)
    |> Task.await()
  end

  def generate_png([]), do: nil

  def generate_png(staves) do
    Task.async(fn ->
      Manuscript.Lilypond.generate_lilypond(staves)
    end)
    |> Task.await()
  end
end
