defmodule ElixirTodoListWeb.TaskLive do
  use ElixirTodoListWeb, :live_view
  alias ElixirTodoList.{Tasks, Task}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, tasks: Tasks.list_tasks(), changeset: Tasks.change_task(%Task{}))}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    case Tasks.create_task(task_params) do
      {:ok, _task} ->
        {:noreply,
         assign(socket,
           tasks: Tasks.list_tasks(),
           changeset: Tasks.change_task(%Task{})
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: %{changeset | action: :insert})}
    end
  end
end

