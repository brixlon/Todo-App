defmodule TodoApp.Tasks do
  @moduledoc """
  The Tasks context handles task creation, retrieval, updating, deletion, and search.
  """

  import Ecto.Query, warn: false
  alias TodoApp.Repo
  alias TodoApp.Tasks.Task

  def list_tasks do
    Repo.all(Task)
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def search_tasks(query) do
    pattern = "%#{query}%"
    from(t in Task,
      where: ilike(t.title, ^pattern) or ilike(t.description, ^pattern)
    )
    |> Repo.all()
  end
end
