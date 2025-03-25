defmodule SubjectManagerWeb.SubjectLive.Index do
  require Logger
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  import SubjectManagerWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Subjects")
      |> assign(subjects: Subjects.list_subjects())
      |> assign(form: to_form(%{}))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="subject-index">
      <.filter_form form={@form} />

      <div class="subjects" id="subjects">
        <div id="empty" class="no-results only:block hidden">
          No subjects found. Try changing your filters.
        </div>
        <.subject :for={subject <- @subjects} subject={subject} dom_id={"subject-#{subject.id}"} />
      </div>
    </div>
    """
  end

  attr(:subject, SubjectManager.Subjects.Subject, required: true)
  attr(:dom_id, :string, required: true)

  def subject(assigns) do
    ~H"""
    <.link navigate={~p"/subjects/#{@subject}"} id={@dom_id}>
      <div class="card">
        <img src={@subject.image_path} />
        <h2>{@subject.name}</h2>
        <div class="details">
          <div class="team">
            {@subject.team}
          </div>
          <.badge status={@subject.position} />
        </div>
      </div>
    </.link>
    """
  end

  attr(:form, Phoenix.HTML.Form, required: true)

  def filter_form(assigns) do
    ~H"""
    <.form phx-change="search" for={@form} id="filter-form" onkeydown="return event.key != 'Enter';">
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" phx-debounce="1000" />
      <.input
        type="select"
        field={@form[:position]}
        prompt="-Position-"
        options={[
          Forward: "forward",
          Midfielder: "midfielder",
          Winger: "winger",
          Defender: "defender",
          Goalkeeper: "goalkeeper"
        ]}
      />
      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="-Sort By-"
        options={[
          Name: "name",
          Team: "team",
          Position: "position"
        ]}
      />

      <.link phx-click="reset">
        Reset
      </.link>
    </.form>
    """
  end

  def handle_event("reset", _params, socket) do
    {
      :noreply,
      socket
      |> assign(subjects: Subjects.list_subjects())
      |> assign(form: to_form(%{"position" => "", "q" => "", "sort_by" => ""}))
    }
  end

  def handle_event(
        "search",
        %{"position" => position, "q" => search_text, "sort_by" => sort_by},
        socket
      ) do
    sort_by =
      if sort_by in [nil, ""] do
        "name"
      else
        sort_by
      end

    criteria = [
      {:filter, [position: position, search: search_text]},
      {:order, [asc: String.to_existing_atom(sort_by)]}
    ]

    {
      :noreply,
      assign(socket, subjects: Subjects.list_subjects(criteria))
    }
  end

  def handle_event(event, params, socket) do
    Logger.error(["ERROR", inspect(event: event, params: params)])
    {:noreply, socket}
  end
end
