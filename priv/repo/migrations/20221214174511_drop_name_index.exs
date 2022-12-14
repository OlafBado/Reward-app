defmodule RewardApp.Repo.Migrations.DropNameIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:users, [:name])
  end
end
