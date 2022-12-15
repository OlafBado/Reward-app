defmodule RewardApp.Repo.Migrations.AddRewardsTable do
  use Ecto.Migration

  def change do
    create table(:rewards) do
      add :name, :string
      add :price, :integer
      add :description, :string
    end

  end
end
