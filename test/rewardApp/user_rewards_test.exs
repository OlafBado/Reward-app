defmodule RewardApp.UserRewardsTest do
  use RewardApp.DataCase, async: true

  import RewardApp.UserRewardsFixtures

  alias RewardApp.Accounts
  alias RewardApp.UserRewards

  @list [
    %{name: "hello", reward: "ticket"},
    %{name: "hello", reward: "snow"},
    %{name: "abc", reward: "house"},
    %{name: "abc", reward: "palm"}
  ]
  @grouped_list [
    %{name: "abc", reward: ["house", "palm"]},
    %{name: "hello", reward: ["ticket", "snow"]}
  ]

  describe "user rewards" do
    test "list_user_rewards/0 returns all user rewards" do
      user_reward_fixture()
      assert length(UserRewards.list_user_rewards()) == 1
    end

    test "get_recent_rewards/0 returns map with user name, reward name and inserted at date" do
      user_reward_fixture()

      [%{inserted_at: inserted_at, reward_name: reward_name, user_name: user_name}] =
        recent_rewards = UserRewards.get_recent_rewards()

      assert length(recent_rewards) == 1

      assert user_name == "regular"
      assert reward_name == "ticket"
      assert inserted_at != nil
    end

    test "create_user_reward/2 with user that has enough points creates a user reward and decrements user's points" do
      {:ok, user} =
        RewardApp.AccountsFixtures.user_fixture()
        |> Accounts.update_user(%{"total_points" => 200})

      reward_id = RewardApp.RewardsFixtures.reward_fixture().id

      assert user.total_points == 200
      assert {:ok, %{user_id: user_id}} = user |> UserRewards.create_user_reward(reward_id)
      assert UserRewards.list_user_rewards() |> length() == 1

      updated_user = RewardApp.Accounts.get_user!(user_id)

      assert updated_user.total_points == 100
    end

    test "create_user_reward/2 returns error if user doesn't have enough points" do
      user = RewardApp.AccountsFixtures.user_fixture()
      reward_id = RewardApp.RewardsFixtures.reward_fixture().id

      assert {:error, %Ecto.Changeset{errors: [total_points: {error, _}]}} =
               user |> UserRewards.create_user_reward(reward_id)

      assert error == "must be greater than or equal to %{number}"
    end

    test "create_naive_date/3 creates naive date with valid data" do
      assert {:ok, ~N[2020-01-01 00:00:00]} = UserRewards.create_naive_date(2020, 1, 1)
    end

    test "create_naive_date/3 returns error with invalid data" do
      assert {:error, :invalid_date} = UserRewards.create_naive_date(2020, 13, 56)
    end

    test "create_date_range/2 return tupple with first day of month and last day of month" do
      assert {start_date, end_date} = UserRewards.create_date_range(2020, 1)

      assert start_date == ~N[2020-01-01 00:00:00]
      assert end_date == ~N[2020-01-31 23:59:59]
    end

    test "create_date_range/2 return error with invalid data" do
      assert {:error, :invalid_date} = UserRewards.create_date_range(2031, -1)
    end

    test "create_query/1 returns query" do
      {start_date, end_date} = UserRewards.create_date_range(2022, 12)

      assert %Ecto.Query{} = UserRewards.create_query({start_date, end_date})
    end

    test "check_for_nil/1 returns true if nested map contains nil" do
      assert UserRewards.check_for_nil([%{reward: nil}])
    end

    test "check_for_nil/1 returns false if nested map doesn't contain nil" do
      refute UserRewards.check_for_nil([%{reward: "ticket"}])
    end

    test "group_list/1 returns a grouped list" do
      assert @grouped_list == UserRewards.group_list(@list)
    end

    test "generate_report/1 returns grouped list" do
      user_reward_fixture()

      assert [%{name: name, reward: [reward]}] =
               UserRewards.generate_report(%{"report" => %{"month" => "12", "year" => "2022"}})

      assert name == "regular"
      assert reward == "ticket"
    end

    test "convert_string_to_month/1 returns correct month given number string" do
      assert "January" == UserRewards.convert_string_to_month("1")
      assert "February" == UserRewards.convert_string_to_month("2")
      assert "March" == UserRewards.convert_string_to_month("3")
      assert "April" == UserRewards.convert_string_to_month("4")
      assert "May" == UserRewards.convert_string_to_month("5")
      assert "June" == UserRewards.convert_string_to_month("6")
      assert "July" == UserRewards.convert_string_to_month("7")
      assert "August" == UserRewards.convert_string_to_month("8")
      assert "September" == UserRewards.convert_string_to_month("9")
      assert "October" == UserRewards.convert_string_to_month("10")
      assert "November" == UserRewards.convert_string_to_month("11")
      assert "December" == UserRewards.convert_string_to_month("12")
    end
  end
end
