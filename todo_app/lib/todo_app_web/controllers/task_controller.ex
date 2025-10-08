defmodule TodoAppWeb.TaskController do
  use TodoAppWeb, :controller

  alias TodoApp.Tasks
  alias TodoApp.Tasks.Task

  def index(conn, _params) do
    tasks = Tasks.list_tasks()
    render(conn, :index, tasks: tasks)
  end

  def new(conn, _params) do
    changeset = Tasks.change_task(%Task{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"task" => task_params}) do
  case Tasks.create_task(task_params) do
    {:ok, _task} ->
      conn
      |> put_flash(:info, "Task created successfully.")
      |> redirect(to: ~p"/tasks")

     {:error, %Ecto.Changeset{} = changeset} ->
      render(conn, :new, changeset: changeset)
     end
  end

  def search(conn, %{"q" => query}) do
    results = Tasks.search_tasks(query)
    render(conn, :index, tasks: results)
  end
end
