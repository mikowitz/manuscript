defmodule ManuscriptWeb.ManuscriptLive do
  use ManuscriptWeb, :live_view

  alias Manuscript.Instrument
  alias Manuscript.Instrument.Template

  def mount(_params, _session, socket) do
    reset(socket, :ok)
  end

  def handle_event("clear_score", _, socket) do
    reset(socket)
  end

  def handle_event("autocomplete", %{"instrument" => instrument}, socket) do
    instruments = Template.matching(instrument)
    {:noreply, assign(socket, search_results: instruments, search_term: instrument)}
  end

  def handle_event("add_instrument", %{"instrument" => instrument}, socket) do
    instrument = Template.by_name(instrument)

    if instrument do
      new_instruments =
        [Instrument.new(instrument) | socket.assigns.instruments]
        |> Enum.sort_by(& &1.template.index)

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

  def reset(socket, resp \\ :noreply) do
    {resp,
     assign(socket,
       search_term: "",
       search_results: [],
       instruments: [],
       score: nil,
       pdf_score: nil,
       generating: false
     )}
  end
end
