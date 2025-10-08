alias TodoApp.Repo
alias TodoApp.Tasks.Task
alias Ecto.Changeset

seed_tasks = [
  %{
    title: "Buy groceries",
    description: "Milk, eggs, bread",
    due_date: Date.utc_today(),
    due_time: ~T[17:00:00],
    repeat: "none"
  },
  %{
    title: "Workout",
    description: "30 min run",
    due_date: Date.utc_today(),
    due_time: ~T[07:30:00],
    repeat: "daily"
  },
  %{
    title: "Read a book",
    description: "Read 20 pages",
    due_date: Date.utc_today() |> Date.add(1),
    due_time: ~T[20:00:00],
    repeat: "none"
  }
]

Enum.each(seed_tasks, fn attrs ->
  %Task{}
  |> Task.changeset(attrs)
  |> case do
    %Changeset{valid?: true} = changeset -> Repo.insert!(changeset)
    invalid_changeset -> raise "Invalid seed task: #{inspect(invalid_changeset.errors)}"
  end
end)

IO.puts("Seeded tasks: #{length(seed_tasks)}")
