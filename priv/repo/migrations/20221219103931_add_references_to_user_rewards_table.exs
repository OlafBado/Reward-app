defmodule RewardApp.Repo.Migrations.AddReferencesToUserRewardsTable do
  use Ecto.Migration

  def change do
    alter table(:user_rewards) do
      add :user_id, references(:users)
      add :reward_id, references(:rewards)
      remove :name
      remove :email
      remove :reward
      remove :cost
    end
  end
end
