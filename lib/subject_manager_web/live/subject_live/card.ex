defmodule SubjectManagerWeb.SubjectLive.Card do
  require Logger
  use SubjectManagerWeb, :live_view

  import SubjectManagerWeb.CustomComponents

  def mount(params, _session, socket) do
    subject_id = Map.get(params, "id")
    subject = SubjectManager.Subjects.get_subject!(subject_id)

    socket =
      socket
      |> assign(page_title: subject.name)
      |> assign(subject: subject)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="headline">
      <h1>{@subject.name}</h1>
    </div>

    <div class="subject-show">
      <div class="subject">
        <section>
          {@subject.team}
          <.badge status={@subject.position} />
          <div class="description">{@subject.bio}</div>
        </section>
        <img src={@subject.image_path} />
      </div>
    </div>
    """
  end
end
