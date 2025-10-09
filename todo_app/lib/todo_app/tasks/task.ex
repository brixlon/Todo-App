defmodule TodoApp.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :due_date, :date
    field :due_time, :time
    field :repeat, :string, default: "none"
    field :completed, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :due_date, :due_time, :repeat, :completed])
    |> validate_required([:title, :description, :due_date, :due_time])
    |> validate_inclusion(:repeat, ["none", "hourly", "daily", "monthly"])
    |> validate_due_date()
  end

  defp validate_due_date(changeset) do
    case get_change(changeset, :due_date) do
      nil ->
        changeset
      date ->
        if Date.compare(date, Date.utc_today()) == :lt do
          add_error(changeset, :due_date, "must be today or a future date")
        else
          changeset
        end
    end
  end
end
