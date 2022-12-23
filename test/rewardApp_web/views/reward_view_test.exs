defmodule RewardAppWeb.RewardViewTest do
  use RewardAppWeb.ConnCase, async: true
  import Phoenix.View
  import RewardApp.RewardsFixtures
  import RewardApp.AccountsFixtures
  alias RewardAppWeb.RewardView
  alias RewardApp.Rewards
  alias RewardApp.Rewards.Reward

  setup %{conn: conn} do
    user = user_fixture()
    conn = assign(conn, :current_user, user)
    {:ok, conn: conn, current_user: user}
  end

  test "renders edit.html", %{conn: conn} do
    reward = reward_fixture()
    changeset = Rewards.change_reward(reward)

    content =
      render_to_string(RewardView, "edit.html",
        conn: conn,
        reward: reward,
        changeset: changeset
      )

    assert String.contains?(content, "Edit #{reward.name}")
    assert String.contains?(content, reward.name)
    assert String.contains?(content, reward.description)
  end

  test "renders index.html", %{conn: conn, current_user: current_user} do
    rewards = [
      reward_fixture(),
      reward_fixture(%{name: "house", description: "big house"})
    ]

    content =
      render_to_string(RewardView, "index.html",
        conn: conn,
        rewards: rewards,
        current_user: current_user
      )

    assert String.contains?(content, "Choose a reward")

    for reward <- rewards do
      assert String.contains?(content, reward.name)
      assert String.contains?(content, reward.description)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Rewards.change_reward(%Reward{})

    content =
      render_to_string(RewardView, "new.html",
        conn: conn,
        changeset: changeset
      )

    assert String.contains?(content, "Add reward")
  end
end
