defmodule RewardApp.Repo.Migrations.AddDeletedFlagToRewards do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      add :deleted, :boolean, default: false
    end
  end
end
