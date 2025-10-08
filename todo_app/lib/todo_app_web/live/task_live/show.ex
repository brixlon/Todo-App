defmodule TodoAppWeb.TaskLive.Show do
  use TodoAppWeb, :live_view

  alias TodoApp.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Task {@task.id}
        <:subtitle>This is a task record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/tasks"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/tasks/#{@task}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit task
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@task.title}</:item>
        <:item title="Description">{@task.description}</:item>
        <:item title="Due date">{@task.due_date}</:item>
        <:item title="Due time">{@task.due_time}</:item>
        <:item title="Repeat">{@task.repeat}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Task")
     |> assign(:task, Tasks.get_task!(id))}
  end
end
