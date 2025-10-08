defmodule TodoApp.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :due_date, :date
    field :due_time, :time
    field :repeat, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :due_date, :due_time, :repeat])
    |> validate_required([:title, :description, :due_date, :due_time, :repeat])
  end
  
end
