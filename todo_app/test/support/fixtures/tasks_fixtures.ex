defmodule TodoApp.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoApp.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        due_date: ~D[2025-10-07],
        due_time: ~T[14:00:00],
        repeat: "some repeat",
        title: "some title"
      })
      |> TodoApp.Tasks.create_task()

    task
  end
end
