defmodule SubjectManager.Subjects do
  import Ecto.Query, warn: false

  alias SubjectManager.Repo
  alias SubjectManager.Subjects.Subject

  def list_subjects() do
    Repo.all(Subject)
  end

  def get_subject!(id) do
    Repo.get!(Subject, id)
  end

  def list_subjects(criteria) when is_list(criteria) do
    query = from(s in Subject)

    criteria
    |> Enum.reduce(query, fn
      {:filter, filters}, query ->
        filter_with(filters, query)

      {:order, val}, query ->
        from p in query, order_by: ^val
    end)
    |> Repo.all()
  end

  defp filter_with(filters, query) do
    filters
    |> Enum.reject(fn {_, value} -> value == "" end)
    |> Enum.reduce(query, fn
      {:search, value}, query ->
        pattern = "%#{value}%"

        from q in query,
          where: like(q.name, ^pattern)

      # like(q.team, ^pattern) or
      # like(q.bio, ^pattern)

      {:position, value}, query ->
        from q in query, where: q.position == ^value
    end)
  end
end
