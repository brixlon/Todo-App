defmodule TodoAppWeb.TaskLive.Index do
  use TodoAppWeb, :live_view
  alias TodoApp.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:search_query, "")
     |> assign(:tasks, Tasks.list_tasks())
     |> assign(:page_title, "All Tasks")
     |> assign(:show_task, nil)} # holds currently selected task for modal
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  # SEARCH
  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    tasks =
      if query == "" do
        Tasks.list_tasks()
      else
        Tasks.search_tasks(query)
      end

    {:noreply, assign(socket, search_query: query, tasks: tasks)}
  end

  # DELETE
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)
    new_tasks = Enum.reject(socket.assigns.tasks, fn t -> t.id == task.id end)

    {:noreply,
     socket
     |> put_flash(:info, "Task deleted successfully")
     |> assign(:tasks, new_tasks)}
  end

  # TOGGLE COMPLETE
  @impl true
  def handle_event("toggle_complete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.toggle_complete(task)

    updated_tasks =
      Enum.map(socket.assigns.tasks, fn t ->
        if t.id == task.id, do: %{t | completed: !t.completed}, else: t
      end)

    {:noreply,
     socket
     |> put_flash(:info, "Task marked as #{if task.completed, do: "incomplete", else: "complete"}")
     |> assign(:tasks, updated_tasks)}
  end

  # SHOW TASK DETAILS
  @impl true
  def handle_event("show", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:noreply, assign(socket, show_task: task)}
  end

  # CLOSE MODAL
  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_task: nil)}
  end

  # SORT TASKS: incomplete due soon → incomplete → completed
  defp sort_tasks(tasks) do
    Enum.sort_by(tasks, fn task ->
      completed = task.completed
      due_soon = Tasks.is_due_soon?(task)
      date = task.due_date || ~D[9999-12-31]
      time = task.due_time || ~T[23:59:59]

      priority =
        cond do
          completed -> 2
          due_soon -> 0
          true -> 1
        end

      {priority, date, time}
    end)
  end

  # CSS Helpers
  defp task_classes(task) do
    cond do
      task.completed -> "bg-green-50 border-green-300 opacity-75"
      Tasks.is_due_soon?(task) -> "bg-amber-50 border-amber-300 shadow-md"
      true -> "bg-gray-50 border-gray-200"
    end
  end

  defp text_classes(task) do
    cond do
      task.completed -> "line-through text-green-900"
      Tasks.is_due_soon?(task) -> "text-amber-900"
      true -> "text-gray-600"
    end
  end

  defp subtext_classes(task) do
    cond do
      task.completed -> "text-green-700"
      Tasks.is_due_soon?(task) -> "text-amber-800"
      true -> "text-gray-500"
    end
  end

  defp repeat_classes(task) do
    cond do
      task.completed -> "bg-green-200 text-green-900"
      Tasks.is_due_soon?(task) -> "bg-amber-200 text-amber-900"
      true -> "bg-gray-200 text-gray-700"
    end
  end

  # Unified UI helpers for action buttons and badges
  defp action_btn_classes(:toggle, task) do
    base =
      "group inline-flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 shadow-sm hover:shadow-md active:shadow-sm"

    variant =
      if task.completed do
        "bg-gradient-to-br from-slate-700 to-slate-800 hover:from-slate-800 hover:to-slate-900 text-white focus:ring-slate-400"
      else
        "bg-gradient-to-br from-emerald-600 to-emerald-700 hover:from-emerald-600/90 hover:to-emerald-800 text-white focus:ring-emerald-400"
      end

    base <> " " <> variant
  end

  defp action_btn_classes(:edit, _task) do
    "group inline-flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 shadow-sm hover:shadow-md active:shadow-sm bg-gradient-to-br from-indigo-600 to-indigo-700 hover:from-indigo-600/90 hover:to-indigo-800 text-white focus:ring-indigo-400"
  end

  defp action_btn_classes(:delete, _task) do
    "group inline-flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 shadow-sm hover:shadow-md active:shadow-sm bg-gradient-to-br from-rose-600 to-rose-700 hover:from-rose-600/90 hover:to-rose-800 text-white focus:ring-rose-400"
  end

  defp almost_due_badge_classes do
    "w-full text-center px-3 py-2 rounded-lg bg-amber-500 text-white text-xs font-extrabold tracking-wider shadow-sm uppercase animate-pulse"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-indigo-50 to-purple-50 p-6">
      <div class="max-w-4xl mx-auto">
        <div class="bg-white rounded-2xl shadow-xl p-8">
          <div class="flex items-center justify-between mb-8">
            <h1 class="text-3xl font-bold text-gray-800"><%= @page_title %></h1>
            <.link
              patch={~p"/tasks/new"}
              class="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors shadow-md"
            >
              ➕ New Task
            </.link>
          </div>

          <div class="mb-6">
            <div class="relative">
              <.form for={%{}} id="task-search" phx-change="search" phx-debounce="300">
                <input
                  type="text"
                  name="query"
                  value={@search_query}
                  placeholder="🔍 Search by name or date..."
                  class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
                />
              </.form>
            </div>
          </div>

          <div class="space-y-4">
            <%= if @tasks == [] do %>
              <div class="text-center py-12 text-gray-500">
                <div class="text-6xl mb-4">📋</div>
                <p class="text-lg">No tasks found</p>
              </div>
            <% else %>
              <%= for task <- sort_tasks(@tasks) do %>
                <% due_soon = Tasks.is_due_soon?(task) %>
                <div class={"p-6 rounded-lg border-2 transition-all " <> task_classes(task)}>
                  <div class="flex justify-between items-start">
                    <div class="flex-1 cursor-pointer" phx-click="show" phx-value-id={task.id}>
                      <div class="flex items-center gap-3 mb-2">
                        <h3 class={"text-xl font-bold " <> text_classes(task)}><%= task.title %></h3>
                        <%= if task.completed do %>
                          <span class="px-2 py-1 bg-green-600 text-white text-xs font-bold rounded-full">
                            ✓ DONE
                          </span>
                        <% end %>
                      </div>
                      <p class={"mb-3 " <> subtext_classes(task)}><%= task.description %></p>

                      <div class="flex gap-4 text-sm mb-3">
                        <%= if task.due_date do %>
                          <span class={"flex items-center gap-1 " <> subtext_classes(task)}>
                            📅 <%= Calendar.strftime(task.due_date, "%Y-%m-%d") %>
                          </span>
                        <% end %>
                        <%= if task.due_time do %>
                          <span class={"flex items-center gap-1 " <> subtext_classes(task)}>
                            🕐 <%= Calendar.strftime(task.due_time, "%H:%M") %>
                          </span>
                        <% end %>
                        <%= if task.repeat && task.repeat != "none" do %>
                          <span class={"px-2 py-1 rounded text-xs font-semibold " <> repeat_classes(task)}>
                            🔄 Repeats <%= task.repeat %>
                          </span>
                        <% end %>
                      </div>
                    </div>

                    <div class="flex flex-col gap-2">
                      <!-- TOGGLE COMPLETE -->
                      <button
                        phx-click="toggle_complete"
                        phx-value-id={task.id}
                        class={action_btn_classes(:toggle, task)}
                      >
                        <%= if task.completed, do: "↩️ Mark Incomplete", else: "✓ Mark Complete" %>
                      </button>

                      <!-- EDIT -->
                      <.link
                        patch={~p"/tasks/#{task}/edit"}
                        class={action_btn_classes(:edit, task)}
                      >
                        ✏️ Edit
                      </.link>

                      <!-- DELETE -->
                      <button
                        phx-click="delete"
                        phx-value-id={task.id}
                        data-confirm="Are you sure you want to delete this task?"
                        class={action_btn_classes(:delete, task)}
                      >
                        🗑️ Delete
                      </button>
                    </div>
                  </div>

                  <div class="mt-4">
                    <%= if due_soon and !task.completed do %>
                      <span class={almost_due_badge_classes()}>
                        ALMOST DUE
                      </span>
                    <% end %>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>

          <!-- TASK DETAILS MODAL -->
          <%= if @show_task do %>
            <div
              class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
              phx-click="close_modal"
            >
              <div class="bg-white rounded-xl p-6 max-w-md w-full shadow-lg" phx-click="noop">
                <h2 class="text-2xl font-bold mb-4"><%= @show_task.title %></h2>
                <p class="mb-2"><strong>Description:</strong> <%= @show_task.description %></p>
                <%= if @show_task.due_date do %>
                  <p class="mb-2"><strong>Due Date:</strong> <%= Calendar.strftime(@show_task.due_date, "%Y-%m-%d") %></p>
                <% end %>
                <%= if @show_task.due_time do %>
                  <p class="mb-2"><strong>Due Time:</strong> <%= Calendar.strftime(@show_task.due_time, "%H:%M") %></p>
                <% end %>
                <%= if @show_task.repeat && @show_task.repeat != "none" do %>
                  <p class="mb-2"><strong>Repeats:</strong> <%= @show_task.repeat %></p>
                <% end %>

                <div class="mt-6">
                  <button
                    phx-click="close_modal"
                    class="w-full px-4 py-2 bg-gray-800 text-white rounded-lg hover:bg-gray-900 transition-colors"
                  >
                    Close
                  </button>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
