defmodule RewardApp.RewardsFixtures do
  def reward_fixture(attrs \\ %{}) do
    {:ok, reward} =
      attrs
      |> Enum.into(%{
        name: "ticket",
        description: "simple ticket",
        price: "100"
      })
      |> RewardApp.Rewards.create_reward()

    reward
  end
end
