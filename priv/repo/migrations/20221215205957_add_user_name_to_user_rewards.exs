defmodule RewardApp.Repo.Migrations.AddUserNameToUserRewards do
  use Ecto.Migration

  def change do
    alter table(:user_rewards) do
      add :name, :string
    end

    rename table(:user_rewards), :user, to: :email
  end
end
