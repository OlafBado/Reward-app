defmodule RewardApp.UserRewardsFixtures do
  def user_reward_fixture do
    reward = RewardApp.RewardsFixtures.reward_fixture()

    {:ok, user} =
      RewardApp.AccountsFixtures.user_fixture()
      |> RewardApp.Accounts.update_user(%{"total_points" => 200})

    RewardApp.UserRewards.create_user_reward(user, reward.id)
  end
end
