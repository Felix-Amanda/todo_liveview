defmodule ElixirTodoListWeb.PageController do
  use ElixirTodoListWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
