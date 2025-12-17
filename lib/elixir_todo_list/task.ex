defmodule ElixirTodoList.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :completed, :boolean, default: false
    timestamps(type: :utc_datetime)
  end

  def changeset(task_struct, attrs) do
    task_struct
    |> cast(attrs, [:title, :completed])
    |> validate_required([:title])
  end
end
