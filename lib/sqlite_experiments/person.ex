defmodule SqliteExperiments.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :name, :string
    field :age, :integer, default: 0
  end

  def changeset(struct, params) do
    cast(struct, params, [:name, :age])
  end
end
