defmodule TodoAppWeb.TaskLive.Index do
  use TodoAppWeb, :live_view

  alias TodoApp.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Tasks
        <:actions>
          <.button variant="primary" navigate={~p"/tasks/new"}>
            <.icon name="hero-plus" /> New Task
          </.button>
        </:actions>
      </.header>

      <.table
        id="tasks"
        rows={@streams.tasks}
        row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}") end}
      >
        <:col :let={{_id, task}} label="Title">{task.title}</:col>
        <:col :let={{_id, task}} label="Description">{task.description}</:col>
        <:col :let={{_id, task}} label="Due date">{task.due_date}</:col>
        <:col :let={{_id, task}} label="Due time">{task.due_time}</:col>
        <:col :let={{_id, task}} label="Repeat">{task.repeat}</:col>
        <:action :let={{_id, task}}>
          <div class="sr-only">
            <.link navigate={~p"/tasks/#{task}"}>Show</.link>
          </div>
          <.link navigate={~p"/tasks/#{task}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, task}}>
          <.link
            phx-click={JS.push("delete", value: %{id: task.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Tasks")
     |> stream(:tasks, list_tasks())}
  end
def handle_event("search", %{"query" => query}, socket) do
  tasks = TodoApp.Tasks.search_tasks(query)
  {:noreply, assign(socket, :tasks, tasks)}
end

def handle_event("sort", %{"sort" => sort}, socket) do
  tasks = TodoApp.Tasks.sort_tasks(sort)
  {:noreply, assign(socket, :tasks, tasks)}
end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  defp list_tasks() do
    Tasks.list_tasks()
  end
end
