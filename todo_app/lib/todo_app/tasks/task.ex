defmodule TodoApp.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :date, :date
    field :time, :time
    field :repeat, :string

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :date, :time, :repeat])
    |> validate_required([:title, :description, :date, :time])
  end
end
