defmodule ManuscriptWeb.ManuscriptLive do
  use ManuscriptWeb, :live_view

  alias Manuscript.{Score, Score.Staff}

  def mount(_params, _session, socket) do
    reset(socket, :ok)
  end

  def handle_event("clear_score", _, socket) do
    reset(socket)
  end

  def handle_event("autocomplete", %{"instrument" => instrument}, socket) do
    instruments = Score.instruments_matching(instrument)
    {:noreply, assign(socket, search_results: instruments, search_term: instrument)}
  end

  def handle_event("add_instrument", %{"instrument" => instrument}, socket) do
    instrument = Score.instrument_by_name(instrument)

    if instrument do
      new_instruments =
        [Staff.new(instrument) | socket.assigns.instruments]
        |> Enum.sort_by(& &1.instrument.index)

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

  def handle_event("update_score", _params, socket) do
    IO.puts("OK")

    send(
      self(),
      {:generate_lilypond,
       socket.assigns.instruments
       |> Enum.sort_by(& &1.instrument.index)}
    )

    {:noreply, assign(socket, generating: true)}
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
    IO.puts("OK")
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
      Manuscript.Lilypond.generate_png_data(staves)
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

  def instrument_form(assigns) do
    ~H"""
    <.form for={nil} phx-change="autocomplete" phx-submit="add_instrument">
      <div>
        <.input
          type="text"
          name="instrument"
          id="instrument"
          value={@search_term}
          list="instruments"
          label="Add instrument"
        />
      </div>
    </.form>

    <datalist id="instruments">
      <%= for inst <- @search_results do %>
        <option phx-click="add_instrument" value={inst.name}><%= inst.name %></option>
      <% end %>
    </datalist>
    """
  end

  def score_buttons(assigns) do
    ~H"""
    <div class="buttons">
      <a phx-click="clear_score" class="clear-button">
        Clear
      </a>
      &nbsp;
      <a phx-click="update_score" class="download-button">
        Update
      </a>
    </div>
    """
  end

  def score(assigns) do
    ~H"""
    <div :if={@score} id="score" class="col-span-2">
      <div class="buttons">
        <a download href={@pdf_score} class="download-button">
          Download (PDF)
        </a>
        &nbsp;
        <a download href={@score} class="download-button">
          Download (PNG)
        </a>
      </div>
      <img class="border-2 rounded-lg" src={@score} />
    </div>
    """
  end

  def instrument_list(assigns) do
    ~H"""
    <ul>
      <%= for staff <- @staves do %>
        <.instrument staff={staff} />
      <% end %>
    </ul>
    """
  end

  def instrument(assigns) do
    ~H"""
    <li class="border-2 rounded-lg px-2 py-2 mr-10 ml-2 mt-2">
      <a href="#" phx-click="delete_instrument" phx-value-id={@staff.id} class="text-red-500">
        [x]
      </a>
      <%= @staff.instrument.name %>
    </li>
    """
  end
end
