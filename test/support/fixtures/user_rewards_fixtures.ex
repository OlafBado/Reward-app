defmodule RewardApp.UserRewardsFixtures do
  alias RewardApp.{Accounts, UserRewards, RewardsFixtures, AccountsFixtures}

  def user_reward_fixture(user_attrs \\ %{}, reward_attrs \\ %{}) do
    reward = RewardsFixtures.reward_fixture(reward_attrs)

    {:ok, user} =
      AccountsFixtures.user_fixture(user_attrs)
      |> Accounts.update_user(%{"total_points" => 200})

    UserRewards.create_user_reward(user, reward.id)
  end
end
