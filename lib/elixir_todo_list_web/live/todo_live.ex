defmodule ElixirTodoListWeb.TodoLive do
  use ElixirTodoListWeb, :live_view

  # Estado inicial do LiveView
  @impl true
  def mount(_params, _session, socket) do
    tasks = [
      %{id: 1, title: "Comprar leite", completed: false},
      %{id: 2, title: "Aprender LiveView", completed: true}
    ]

    socket =
      assign(socket,
        tasks: tasks,
        new_task_title: ""
      )

    {:ok, socket}
  end

  # Evento disparado a cada digitação
  @impl true
  def handle_event("update_form", %{"title" => new_title}, socket) do
    {:noreply, assign(socket, new_task_title: new_title)}
  end

  # Evento disparado ao enviar o formulário
  @impl true
  def handle_event("save_task", %{"title" => title}, socket) do
    if String.trim(title) != "" do
      new_task = %{
        id: System.unique_integer([:positive]),
        title: title,
        completed: false
      }

      socket =
        socket
        |> update(:tasks, fn tasks -> tasks ++ [new_task] end)
        |> assign(:new_task_title, "")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # Renderização da interface
  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full max-w-lg mx-auto mt-12 p-6 bg-white rounded-lg shadow-md">
      <h1 class="text-3xl font-bold mb-6 text-center text-gray-800">
        Minha Lista de Tarefas
      </h1>

      <!-- Formulário -->
      <form phx-submit="save_task" phx-change="update_form" class="flex gap-2 mb-6">
        <input
          type="text"
          name="title"
          value={@new_task_title}
          placeholder="O que precisa ser feito?"
          class="flex-grow p-2 border rounded"
          autofocus
        />
        <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
          Adicionar
        </button>
      </form>

      <!-- Lista de tarefas -->
      <ul class="space-y-2">
        <li :for={task <- @tasks} class="flex items-center gap-2">
          <input type="checkbox" checked={task.completed} disabled />
          <span class={if task.completed, do: "line-through text-gray-400", else: "text-gray-900"}>
            <%= task.title %>
          </span>
        </li>
      </ul>
    </div>
    """
  end
end

