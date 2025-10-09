
defmodule TodoAppWeb.TaskLive.Form do
  use TodoAppWeb, :live_view
  alias TodoApp.Tasks
  alias TodoApp.Tasks.Task

  @impl true
  def mount(params, _session, socket) do
    {:ok, socket |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    task = Tasks.get_task!(id)
    changeset = Tasks.change_task(task)

    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, task)
    |> assign(:form, to_form(changeset))
  end

  defp apply_action(socket, :new, _params) do
    changeset = Tasks.change_task(%Task{})

    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{})
    |> assign(:form, to_form(changeset))
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Tasks.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.live_action, task_params)
  end

  defp save_task(socket, :edit, task_params) do
    case Tasks.update_task(socket.assigns.task, task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully")
         |> push_navigate(to: ~p"/tasks")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_task(socket, :new, task_params) do
    case Tasks.create_task(task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_navigate(to: ~p"/tasks")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-indigo-100 via-purple-50 to-pink-100 p-6">
      <div class="max-w-2xl mx-auto">
        <div class="bg-white rounded-2xl shadow-2xl p-8">
          <div class="flex items-center justify-between mb-8">
            <h1 class="text-3xl font-bold text-gray-800"><%= @page_title %></h1>
            <.link
              navigate={~p"/tasks"}
              class="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors shadow-md"
            >
              📋 View Tasks
            </.link>
          </div>

          <.form
            for={@form}
            phx-submit="save"
            class="space-y-6"
          >
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Task Title
              </label>
              <input
                type="text"
                name="task[title]"
                value={@form[:title].value}
                placeholder="Enter task title"
                class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
              />
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Description
              </label>
              <textarea
                name="task[description]"
                rows="4"
                placeholder="Enter task description"
                class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all resize-none"
              ><%= @form[:description].value %></textarea>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  📅 Date
                </label>
                <input
                  type="date"
                  name="task[due_date]"
                  value={@form[:due_date].value}
                  class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
                />
              </div>

              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  🕐 Time
                </label>
                <input
                  type="time"
                  name="task[due_time]"
                  value={@form[:due_time].value}
                  class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                🔄 Repeat Task
              </label>
              <select
                name="task[repeat]"
                class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all bg-white"
              >
                <option value="none" selected={@form[:repeat].value == "none"}>None</option>
                <option value="hourly" selected={@form[:repeat].value == "hourly"}>Hourly</option>
                <option value="daily" selected={@form[:repeat].value == "daily"}>Daily</option>
                <option value="monthly" selected={@form[:repeat].value == "monthly"}>Monthly</option>
              </select>
            </div>

            <button
              type="submit"
              class="w-full flex items-center justify-center gap-2 px-6 py-4 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg hover:shadow-xl transform hover:scale-105"
            >
              <%= if @live_action == :edit do %>
                ✏️ Update Task
              <% else %>
                ➕ Add Task
              <% end %>
            </button>
          </.form>
        </div>
      </div>
    </div>
    """
  end

end
