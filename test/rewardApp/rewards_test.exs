defmodule RewardApp.RewardsTest do
  use RewardApp.DataCase, async: true

  alias RewardApp.Rewards
  alias RewardApp.Rewards.Reward

  @valid_attrs %{name: "snow", description: "cold snow", price: 20}
  @invalid_attrs %{name: nil, description: nil, price: nil}

  describe "list_rewards/0" do
    test "list_rewards/0 returns all rewards" do
      reward_fixture()
      assert length(Rewards.list_rewards()) == 1
    end
  end

  describe "get_reward!/1" do
    test "returns the reward with given id" do
      reward = reward_fixture()
      assert Rewards.get_reward!(reward.id).id == reward.id
    end

    test "raises if reward does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Rewards.get_reward!(123)
      end
    end
  end

  describe "create_reward/1" do
    test "with valid data creates a reward" do
      assert {:ok, %Reward{} = reward} = Rewards.create_reward(@valid_attrs)
      assert reward.name == "snow"
      assert reward.description == "cold snow"
      assert reward.price == 20
    end

    test "with invalid data returns error changeset" do
      assert {:error, changeset} = Rewards.create_reward()

      assert %{
               description: ["can't be blank"],
               name: ["can't be blank"],
               price: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "with negative price returns error changeset" do
      assert {:error, changeset} = Rewards.create_reward(Map.put(@valid_attrs, :price, -10))

      assert %{price: ["Price can't be negative"]} == errors_on(changeset)
    end
  end

  describe "update_reward/2" do
    setup do
      {:ok, reward: reward_fixture()}
    end

    test "with valid data updates the reward", %{reward: reward} do
      assert {:ok, new_reward} = Rewards.update_reward(reward, @valid_attrs)
      assert new_reward.name == "snow"
      assert new_reward.description == "cold snow"
      assert new_reward.price == 20
    end

    test "with invalid data returns error changeset", %{reward: reward} do
      assert {:error, changeset} = Rewards.update_reward(reward, @invalid_attrs)

      assert %{
               description: ["can't be blank"],
               name: ["can't be blank"],
               price: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "with blank name returns error changeset", %{reward: reward} do
      assert {:error, changeset} = Rewards.update_reward(reward, Map.put(@valid_attrs, :name, ""))
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    test "with blank description returns error changeset", %{reward: reward} do
      assert {:error, changeset} =
               Rewards.update_reward(reward, Map.put(@valid_attrs, :description, ""))

      assert %{description: ["can't be blank"]} == errors_on(changeset)
    end

    test "with negative price returns error changeset", %{reward: reward} do
      assert {:error, changeset} =
               Rewards.update_reward(reward, Map.put(@valid_attrs, :price, -10))

      assert %{price: ["Price can't be negative"]} == errors_on(changeset)
    end
  end

  describe "change_reward/1" do
    test "returns reward changeset" do
      assert %Ecto.Changeset{} = Rewards.change_reward(%Reward{})
    end
  end
end
