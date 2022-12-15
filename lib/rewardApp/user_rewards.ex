defmodule RewardApp.UserRewards do
  import Ecto.Query, warn: false

  alias RewardApp.Repo
  alias RewardApp.UserRewards.UserReward
  alias RewardApp.Accounts
  alias RewardApp.Rewards

  def list_user_rewards do
    Repo.all(UserReward)
  end

  def create_user_reward(user,  reward_id \\ %{}) do
    reward = Rewards.get_reward!(reward_id)

    case Accounts.update_user_points(user, %{:total_points => user.total_points - reward.price}) do
      {:ok, _user} ->
        %UserReward{}
        |> UserReward.changeset(%{:name => user.name, :email => user.email, :reward => reward.name, :cost => reward.price})
        |> Repo.insert()
      {:error, changeset} ->
        {:error, changeset}
    end

  end
end
