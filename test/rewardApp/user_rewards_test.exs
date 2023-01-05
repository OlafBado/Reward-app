defmodule RewardApp.UserRewardsTest do
  use RewardApp.DataCase, async: true

  alias RewardApp.{Accounts, UserRewards}

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

  describe "list_user_rewards/0" do
    test "returns all user rewards" do
      user_reward_fixture()
      assert length(UserRewards.list_user_rewards()) == 1
    end
  end

  describe "get_recent_rewards/0" do
    test "returns map with user name, reward name and inserted at date" do
      user_reward_fixture()

      [%{inserted_at: inserted_at, reward_name: reward_name, user_name: user_name}] =
        recent_rewards = UserRewards.get_recent_rewards()

      assert length(recent_rewards) == 1

      assert user_name == "regular"
      assert reward_name == "ticket"
      assert inserted_at != nil
    end
  end

  describe "create_user_reward/2" do
    test "creates a user reward and decrements user's points" do
      {:ok, user} =
        user_fixture()
        |> Accounts.update_user(%{"total_points" => 200})

      reward_id = reward_fixture().id

      assert user.total_points == 200
      assert {:ok, %{user_id: user_id}} = user |> UserRewards.create_user_reward(reward_id)
      assert UserRewards.list_user_rewards() |> length() == 1

      assert Accounts.get_user!(user_id).total_points == 100
    end

    test "returns error if user doesn't have enough points" do
      user = user_fixture()
      reward_id = reward_fixture().id

      assert {:error, changeset} = user |> UserRewards.create_user_reward(reward_id)

      assert %{total_points: ["You don't have enough points"]} == errors_on(changeset)
    end
  end

  describe "create_naive_date/3" do
    test "creates naive date with valid data" do
      assert {:ok, ~N[2020-01-01 00:00:00]} = UserRewards.create_naive_date(2020, 1, 1)
    end

    test "returns error with invalid data" do
      assert {:error, :invalid_date} = UserRewards.create_naive_date(2020, 13, 56)
    end
  end

  describe "create_date_range/2" do
    test "returns tupple with first day of month and last day of month" do
      assert {start_date, end_date} = UserRewards.create_date_range(2020, 1)

      assert start_date == ~N[2020-01-01 00:00:00]
      assert end_date == ~N[2020-01-31 23:59:59]
    end

    test "returns error with invalid data" do
      assert {:error, :invalid_date} = UserRewards.create_date_range(2031, -1)
    end
  end

  describe "create_query/1" do
    test "create_query/1 returns query" do
      {start_date, end_date} = UserRewards.create_date_range(2022, 12)

      assert %Ecto.Query{} = UserRewards.create_query({start_date, end_date})
    end
  end

  describe "group_list/1" do
    test "group_list/1 returns a grouped list" do
      assert @grouped_list == UserRewards.group_list(@list)
    end
  end

  describe "generate_report/1" do
    test "returns grouped list" do
      user_reward_fixture()
      {{year, month, _}, _} = :calendar.local_time()

      assert [%{name: name, reward: [reward]}] =
               UserRewards.generate_report(%{
                 "report" => %{"month" => to_string(month), "year" => to_string(year)}
               })

      assert name == "regular"
      assert reward == "ticket"
    end
  end

  describe "convert_string_to_month/1" do
    test "returns correct month given number string" do
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

    test "returns error if given invalid string" do
      assert {:error, :invalid_month} == UserRewards.convert_string_to_month("13")
    end
  end
end
