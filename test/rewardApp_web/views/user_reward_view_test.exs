defmodule RewardAppWeb.UserRewardViewTest do
  use RewardAppWeb.ConnCase, async: true
  import Phoenix.View
  alias RewardAppWeb.UserRewardView

  test "renders index.html", %{conn: conn} do
    user_rewards = [
      %{user_name: "hello", reward_name: "snow"},
      %{user_name: "abc", reward_name: "house"}
    ]

    content =
      render_to_string(UserRewardView, "index.html", conn: conn, user_rewards: user_rewards)

    assert String.contains?(content, "Recent rewards")

    for user_reward <- user_rewards do
      assert String.contains?(content, user_reward.user_name)
      assert String.contains?(content, user_reward.reward_name)
    end
  end

  test "renders new.html", %{conn: conn} do
    content = render_to_string(UserRewardView, "new.html", conn: conn)

    assert String.contains?(content, "Select year and month to generate the report")
  end

  test "renders show.html", %{conn: conn} do
    users = [
      %{name: "hello", reward: ["ticket"]},
      %{name: "abc", reward: ["house"]}
    ]

    content =
      render_to_string(UserRewardView, "show.html",
        conn: conn,
        users: users,
        year: 2022,
        month: 12
      )

    assert String.contains?(content, "report")

    for user <- users do
      assert String.contains?(content, user.name)
      assert String.contains?(content, user.reward)
    end
  end
end
