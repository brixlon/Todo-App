
defmodule TodoApp.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias TodoApp.Repo
  alias TodoApp.Tasks.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Searches tasks by title, description, or date.

  ## Examples

      iex> search_tasks("meeting")
      [%Task{}, ...]

  """
  def search_tasks(query) do
    pattern = "%#{query}%"

    from(t in Task,
      where:
        ilike(t.title, ^pattern) or
        ilike(t.description, ^pattern) or
        fragment("CAST(? AS TEXT) LIKE ?", t.due_date, ^pattern)
    )
    |> Repo.all()
  end

  @doc """
  Sorts tasks by inserted_at timestamp.

  ## Examples

      iex> sort_tasks("asc")
      [%Task{}, ...]

  """
  def sort_tasks(sort) do
    tasks = list_tasks()

    case sort do
      "asc" -> Enum.sort_by(tasks, & &1.inserted_at, :asc)
      "desc" -> Enum.sort_by(tasks, & &1.inserted_at, :desc)
      _ -> tasks
    end
  end

  @doc """
  Checks if a task is due within the next 24 hours.

  ## Examples

      iex> is_due_soon?(%Task{due_date: ~D[2025-10-08], due_time: ~T[14:00:00]})
      true

  """
  def is_due_soon?(%Task{} = task) do
    # Return false if date or time is nil
    if is_nil(task.due_date) or is_nil(task.due_time) do
      false
    else
      now = DateTime.utc_now()

      # Combine date and time into a DateTime
      case DateTime.new(task.due_date, task.due_time) do
        {:ok, task_datetime} ->
          diff_seconds = DateTime.diff(task_datetime, now)
          diff_hours = diff_seconds / 3600

          # Task is due soon if it's within 0-24 hours from now
          diff_hours >= 0 and diff_hours <= 24

        {:error, _} ->
          false
      end
    end
  end
end
