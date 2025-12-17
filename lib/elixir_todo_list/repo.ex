defmodule ElixirTodoList.Repo do
  use Ecto.Repo,
    otp_app: :elixir_todo_list,
    adapter: Ecto.Adapters.SQLite3
end
