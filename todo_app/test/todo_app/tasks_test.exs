defmodule TodoApp.TasksTest do
  use TodoApp.DataCase

  alias TodoApp.Tasks

  describe "tasks" do
    alias TodoApp.Tasks.Task

    import TodoApp.TasksFixtures

    @invalid_attrs %{description: nil, title: nil, due_date: nil, due_time: nil, repeat: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{
        description: "some description",
        title: "some title",
        due_date: ~D[2025-10-07],
        due_time: ~T[14:00:00],
        repeat: "some repeat"
      }

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.description == "some description"
      assert task.title == "some title"
      assert task.due_date == ~D[2025-10-07]
      assert task.due_time == ~T[14:00:00]
      assert task.repeat == "some repeat"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        due_date: ~D[2025-10-08],
        due_time: ~T[15:01:01],
        repeat: "some updated repeat"
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.description == "some updated description"
      assert task.title == "some updated title"
      assert task.due_date == ~D[2025-10-08]
      assert task.due_time == ~T[15:01:01]
      assert task.repeat == "some updated repeat"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
