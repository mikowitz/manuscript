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
      staff = Staff.new(instrument)

      new_staves =
        Map.put_new(socket.assigns.staves, staff.id, staff)

      send(self(), {:generate_lilypond, new_staves})

      {:noreply,
       assign(socket,
         search_term: "",
         search_results: [],
         staves: new_staves,
         generating: true
       )}
    else
      {:noreply, assign(socket, search_term: "")}
    end
  end

  def handle_event("update_score", _params, socket) do
    staves =
      socket.assigns.staves

    send(
      self(),
      {:generate_lilypond, staves}
    )

    {:noreply, assign(socket, generating: true)}
  end

  def handle_event("delete_instrument", %{"id" => id}, socket) do
    staves = Map.delete(socket.assigns.staves, id)
    send(self(), {:generate_lilypond, staves})

    {:noreply,
     assign(socket,
       search_term: "",
       staves: staves,
       generating: !Enum.empty?(staves)
     )}
  end

  def handle_event("update_staff", params, socket) do
    staves =
      Map.update(socket.assigns.staves, params["id"], nil, fn staff ->
        %{staff | name: params["name"], clef: params["clef"]}
      end)

    {:noreply, assign(socket, staves: staves)}
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
      Manuscript.Lilypond.generate_png_data(staves)
    end)
    |> Task.await()
  end

  def reset(socket, resp \\ :noreply) do
    {resp,
     assign(socket,
       search_term: "",
       search_results: [],
       staves: %{},
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
      <%= for {id, staff} <- Enum.sort_by(@staves, fn s -> elem(s, 1).instrument.index end) do %>
        <.instrument id={id} staff={staff} />
      <% end %>
    </ul>
    """
  end

  def instrument(assigns) do
    ~H"""
    <li id={@id} class="border-2 rounded-lg px-2 py-2 mr-10 ml-2 mt-2">
      <a href="#" phx-click="delete_instrument" phx-value-id={@id} class="text-red-500 font-semibold">
        [x]
      </a>
      <.form
        for={nil}
        class="instrument-form"
        phx-change="update_staff"
        id={"form-" <> @id}
        phx-submit="update_staff"
      >
        <input type="hidden" name="id" id={"id" <> @id} value={@id} />
        <.input type="text" name="name" id={"name-" <> @id} value={@staff.name} />
        <.input
          type="select"
          name="clef"
          id={"clef-" <> @id}
          options={Staff.clefs()}
          value={@staff.clef}
        />
      </.form>
    </li>
    """
  end
end
