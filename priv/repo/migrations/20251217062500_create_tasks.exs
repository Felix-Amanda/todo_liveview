defmodule ElixirTodoList.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :completed, :boolean, default: false
      timestamps()
    end
  end
end
defmodule ElixirTodoList.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do

  end
end
