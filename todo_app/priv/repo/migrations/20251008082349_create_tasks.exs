defmodule TodoApp.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :text
      add :date, :date
      add :time, :time
      add :repeat, :string

      timestamps(type: :utc_datetime)
    end
  end
end
