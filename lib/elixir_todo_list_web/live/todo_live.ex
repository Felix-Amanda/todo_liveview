defmodule ElixirTodoListWeb.TodoLive do
  use ElixirTodoListWeb, :live_view

  alias ElixirTodoList.Repo
  alias ElixirTodoList.Tasks.Task

  # ---------------------------
  # Estado inicial do LiveView
  # ---------------------------
  @impl true
  def mount(_params, _session, socket) do
    tasks = Repo.all(Task)

    {:ok,
     assign(socket,
       tasks: tasks,
       new_task_title: "",
       error_message: nil,
       info_message: nil
     )}
  end

  # ---------------------------
  # Evento disparado a cada digitação
  # ---------------------------
  @impl true
  def handle_event("update_form", %{"title" => new_title}, socket) do
    {:noreply, assign(socket, new_task_title: new_title)}
  end

  # ---------------------------
  # Adicionar tarefa
  # ---------------------------
  @impl true
  def handle_event("save_task", %{"title" => title}, socket) do
    if String.trim(title) == "" do
      # Campo vazio → erro
      {:noreply, assign(socket, error_message: "can't be blank")}
    else
      # Salva no banco e atualiza a lista
      changeset = Task.changeset(%Task{}, %{"title" => title})
      
      case Repo.insert(changeset) do
        {:ok, task} ->
          socket =
            socket
            |> update(:tasks, fn tasks -> tasks ++ [task] end)
            |> assign(new_task_title: "", error_message: nil)

          {:noreply, put_flash(socket, :info, "Tarefa adicionada com sucesso!")}

        {:error, _changeset} ->
          {:noreply, assign(socket, error_message: "Erro ao salvar tarefa")}
      end
    end
  end

  # ---------------------------
  # Excluir tarefa
  # ---------------------------

  @impl true
def handle_event("delete", %{"id" => id}, socket) do
  id = String.to_integer(id)
  task = Repo.get(Task, id)
  if task, do: Repo.delete(task)

  # Atualiza a lista e adiciona a mensagem
  new_socket =
    socket
    |> update(:tasks, fn tasks -> Enum.reject(tasks, &(&1.id == id)) end)
    |> assign(:info_message, "✅ Tarefa removida com sucesso!")

  # Agenda a limpeza da mensagem depois de 3 segundos
  Process.send_after(self(), :clear_info_message, 3000)

  {:noreply, new_socket}
end

   @impl true
   def handle_info(:clear_info_message, socket) do
    {:noreply, assign(socket, :info_message, nil)}
   end

   
   @impl true
def handle_event("toggle_complete", %{"id" => id, "task" => task_params}, socket) do
  id = String.to_integer(id)
  task = Repo.get(Task, id)

  if task do
    changeset = Task.changeset(task, %{"completed" => task_params["completed"] == "true"})
    {:ok, _task} = Repo.update(changeset)
  end

  tasks = Repo.all(Task)
  {:noreply, assign(socket, :tasks, tasks)}
end


  # ---------------------------
  # Renderização da interface
  # ---------------------------
  @impl true
def render(assigns) do
  ~H"""
  <div class="w-full max-w-lg mx-auto mt-12 p-6 bg-white rounded-lg shadow-md">
    <h1 class="text-3xl font-bold mb-6 text-center text-gray-800">
      Minha Lista de Tarefas
    </h1>

    <!-- Formulário -->
    <form phx-submit="save_task" phx-change="update_form" class="flex gap-2 mb-2">
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

    <!-- Mensagem de erro -->
    <%= if @error_message do %>
      <p class="text-red-600 mb-2"><%= @error_message %></p>
    <% end %>

    <!-- Mensagem temporária -->
    <%= if @info_message do %>
      <p class="text-green-600 font-semibold mb-2"><%= @info_message %></p>
    <% end %>

    <!-- Lista de tarefas -->
    <ul class="space-y-2">
      <li :for={task <- @tasks} id={"task-#{task.id}"} class="flex items-center justify-between gap-2 p-2 border rounded">
        <% task_form = Task.changeset(task, %{}) |> to_form() %>

        <.form
          for={task_form}
          phx-change="toggle_complete"
          phx-value-id={task.id}
          class="flex-grow flex items-center gap-2"
        >
          <.input
            type="checkbox"
            field={task_form[:completed]}
          />
          <label class={if task.completed, do: "line-through text-gray-400", else: "text-gray-900"}>
            <%= task.title %>
          </label>
        </.form>

        <.button
          type="button"
          phx-click="delete"
          phx-value-id={task.id}
          class="px-2 py-1 bg-red-500 text-white rounded hover:bg-red-700"
        >
          &times;
        </.button>
      </li>
    </ul>
  </div>
  """
end

end
