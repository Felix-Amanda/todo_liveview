defmodule ElixirTodoListWeb.TodoLive do
  use ElixirTodoListWeb, :live_view

  alias ElixirTodoList.Repo
  alias ElixirTodoList.Tasks.Task

  # ---------------------------
  # mount/3
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
  # render/1
  # ---------------------------
  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full max-w-lg mx-auto mt-12 p-6 bg-white rounded-lg shadow-md">
      <h1 class="text-3xl font-bold mb-6 text-center text-gray-800">
        Minha Lista de Tarefas (com DB!)
      </h1>

      <!-- Formulário -->
      <form phx-submit="save_task" phx-change="update_form" class="flex gap-2 mb-4">
        <input
          type="text"
          name="title"
          value={@new_task_title}
          placeholder="O que precisa ser feito?"
          class="input input-bordered input-primary flex-grow"
          autofocus
        />
        <button type="submit" class="btn btn-primary">Adicionar</button>
      </form>

      <!-- Mensagens -->
      <%= if @error_message do %>
        <div class="alert alert-error mb-2 shadow-lg">
          <span><%= @error_message %></span>
        </div>
      <% end %>

      <%= if @info_message do %>
        <div class="alert alert-success mb-2 shadow-lg">
          <span><%= @info_message %></span>
        </div>
      <% end %>

      <!-- Lista de tarefas -->
      <ul class="space-y-2">
        <li :for={task <- @tasks} id={"task-#{task.id}"} class="flex items-center justify-between p-2 border rounded-lg hover:bg-base-200">
          <% task_form = Task.changeset(task, %{}) |> to_form() %>

          <.form
            for={task_form}
            phx-change="toggle_complete"
            phx-value-id={task.id}
            class="flex items-center gap-2 flex-grow"
          >
            <.input type="checkbox" field={task_form[:completed]} class="checkbox checkbox-primary" />
            <label class={
               if task.completed,
               do: "line-through text-gray-400 italic",
               else: "text-gray-900 font-medium"
              }>
            <%= task.title %>
            </label>
          </.form>

          <.button
            type="button"
            phx-click="delete"
            phx-value-id={task.id}
            class="btn btn-error btn-sm"
          >
            &times;
          </.button>
        </li>
      </ul>
    </div>
    """
  end

  # ---------------------------
  # Eventos
  # ---------------------------
  @impl true
  def handle_event("update_form", %{"title" => new_title}, socket) do
    {:noreply, assign(socket, new_task_title: new_title)}
  end

  @impl true
  def handle_event("save_task", %{"title" => title}, socket) do
    if String.trim(title) == "" do
      {:noreply, assign(socket, error_message: "can't be blank")}
    else
      changeset = Task.changeset(%Task{}, %{"title" => title})

      case Repo.insert(changeset) do
        {:ok, task} ->
          socket =
            socket
            |> update(:tasks, fn tasks -> tasks ++ [task] end)
            |> assign(new_task_title: "", error_message: nil)

          {:noreply, assign(socket, info_message: "Tarefa adicionada com sucesso!")}

        {:error, _changeset} ->
          {:noreply, assign(socket, error_message: "Erro ao salvar tarefa")}
      end
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    id = String.to_integer(id)
    task = Repo.get(Task, id)
    if task, do: Repo.delete(task)

    new_socket =
      socket
      |> update(:tasks, fn tasks -> Enum.reject(tasks, &(&1.id == id)) end)
      |> assign(info_message: "✅ Tarefa removida com sucesso!")

    Process.send_after(self(), :clear_info_message, 3000)
    {:noreply, new_socket}
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
    {:noreply, assign(socket, tasks: tasks)}
  end

  @impl true
  def handle_info(:clear_info_message, socket) do
    {:noreply, assign(socket, info_message: nil)}
  end
end

