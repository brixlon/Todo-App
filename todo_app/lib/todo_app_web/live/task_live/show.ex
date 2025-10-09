
defmodule TodoAppWeb.TaskLive.Show do
  use TodoAppWeb, :live_view
  alias TodoApp.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    task = Tasks.get_task!(id)

    {:noreply,
     socket
     |> assign(:page_title, "Task Details")
     |> assign(:task, task)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-indigo-50 to-purple-50 p-6">
      <div class="max-w-3xl mx-auto">
        <div class="bg-white rounded-2xl shadow-xl p-8">
          <div class="flex items-center justify-between mb-8">
            <h1 class="text-3xl font-bold text-gray-800">Task Details</h1>
            <div class="flex gap-2">
              <.link
                patch={~p"/tasks/#{@task}/edit"}
                class="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors"
              >
                ✏️ Edit
              </.link>
              <.link
                navigate={~p"/tasks"}
                class="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                ← Back
              </.link>
            </div>
          </div>

          <% due_soon = Tasks.is_due_soon?(@task) %>

          <div class={[
            "p-8 rounded-lg border-2",
            if(due_soon, do: "bg-amber-50 border-amber-300", else: "bg-gray-50 border-gray-200")
          ]}>
            <%= if due_soon do %>
              <div class="mb-4">
                <span class="px-4 py-2 bg-amber-600 text-white text-sm font-bold rounded-full">
                  ⚠️ ALMOST DUE - Within 24 Hours
                </span>
              </div>
            <% end %>

            <h2 class={[
              "text-3xl font-bold mb-4",
              if(due_soon, do: "text-amber-900", else: "text-gray-800")
            ]}>
              <%= @task.title %>
            </h2>

            <div class="space-y-6">
              <div>
                <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">
                  Description
                </h3>
                <p class={[
                  "text-lg leading-relaxed",
                  if(due_soon, do: "text-amber-800", else: "text-gray-700")
                ]}>
                  <%= @task.description %>
                </p>
              </div>

              <div class="grid grid-cols-2 gap-6">
                <div>
                  <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">
                    Due Date
                  </h3>
                  <div class={[
                    "flex items-center gap-2 text-lg",
                    if(due_soon, do: "text-amber-700 font-semibold", else: "text-gray-700")
                  ]}>
                    <%= if @task.due_date do %>
                      📅 <%= Calendar.strftime(@task.due_date, "%B %d, %Y") %>
                    <% else %>
                      <span class="text-gray-400">Not set</span>
                    <% end %>
                  </div>
                </div>

                <div>
                  <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">
                    Due Time
                  </h3>
                  <div class={[
                    "flex items-center gap-2 text-lg",
                    if(due_soon, do: "text-amber-700 font-semibold", else: "text-gray-700")
                  ]}>
                    <%= if @task.due_time do %>
                      🕐 <%= Calendar.strftime(@task.due_time, "%I:%M %p") %>
                    <% else %>
                      <span class="text-gray-400">Not set</span>
                    <% end %>
                  </div>
                </div>
              </div>

              <%= if @task.repeat && @task.repeat != "none" do %>
                <div>
                  <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">
                    Repeat Schedule
                  </h3>
                  <span class={[
                    "inline-block px-4 py-2 rounded-lg text-sm font-semibold",
                    if(due_soon, do: "bg-amber-200 text-amber-900", else: "bg-gray-200 text-gray-700")
                  ]}>
                    🔄 Repeats <%= String.capitalize(@task.repeat) %>
                  </span>
                </div>
              <% end %>

              <div class="pt-4 border-t border-gray-200">
                <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">
                  Created
                </h3>
                <p class="text-gray-600">
                  <%= Calendar.strftime(@task.inserted_at, "%B %d, %Y at %I:%M %p") %>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
