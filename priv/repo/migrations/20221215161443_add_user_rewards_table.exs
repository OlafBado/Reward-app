defmodule RewardApp.Repo.Migrations.AddUserRewardsTable do
  use Ecto.Migration

  def change do
    create table(:user_rewards) do
      add :user, :string
      add :reward, :string
      add :cost, :integer

      timestamps()
    end
  end

end
