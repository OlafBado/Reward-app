defmodule RewardApp.RewardsTest do
  use RewardApp.DataCase

  alias RewardApp.Rewards

  describe "rewards" do
    alias RewardApp.Rewards.Reward

    import RewardApp.RewardsFixtures

    @valid_attrs %{name: "snow", description: "cold snow", price: 20}
    @invalid_attrs %{name: nil, description: nil, price: nil}
    @invalid_attrs_pirce %{price: -10}
    @invalid_attrs_name %{name: "", description: "example", price: 10}
    @invalid_attrs_description %{name: "abc", description: "", price: 20}

    test "list_rewards/0 returns all rewards" do
      reward_fixture()
      assert length(Rewards.list_rewards()) == 1
    end

    test "get_reward!/1 returns the reward with given id" do
      reward = reward_fixture()
      assert Rewards.get_reward!(reward.id).id == reward.id
    end

    test "create_reward/1 with valid data creates a reward" do
      assert {:ok, %Reward{} = reward} = Rewards.create_reward(@valid_attrs)
      assert reward.name == "snow"
      assert reward.description == "cold snow"
      assert reward.price == 20
    end

    test "create_reward/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rewards.create_reward(@invalid_attrs)
    end

    test "create_reward/1 with negative price returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rewards.create_reward(@invalid_attrs_pirce)
    end

    test "update_reward/2 with valid data updates the reward" do
      reward = reward_fixture()
      assert {:ok, %Reward{} = reward} = Rewards.update_reward(reward, @valid_attrs)
      assert reward.name == "snow"
      assert reward.description == "cold snow"
      assert reward.price == 20
    end

    test "update_reward/2 with invalid data returns error changeset" do
      reward = reward_fixture()
      assert {:error, %Ecto.Changeset{}} = Rewards.update_reward(reward, @invalid_attrs)
    end

    test "update_reward/2 with negative price returns error changeset" do
      reward = reward_fixture()
      assert {:error, %Ecto.Changeset{}} = Rewards.update_reward(reward, @invalid_attrs_pirce)
    end

    test "update_reward/2 with blank name returns error changeset" do
      reward = reward_fixture()
      assert {:error, %Ecto.Changeset{}} = Rewards.update_reward(reward, @invalid_attrs_name)
    end

    test "update_reward/2 with blank description returns error changeset" do
      reward = reward_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Rewards.update_reward(reward, @invalid_attrs_description)
    end

    test "change_reward/1 returns reward changeset" do
      assert %Ecto.Changeset{} = Rewards.change_reward(%Reward{})
    end
  end
end
