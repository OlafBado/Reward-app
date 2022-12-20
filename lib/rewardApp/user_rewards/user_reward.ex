defmodule RewardApp.UserRewards.UserReward do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_rewards" do
    belongs_to :user, RewardApp.Accounts.User
    belongs_to :reward, RewardApp.Rewards.Reward

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :reward_id])
    |> validate_required([:user_id, :reward_id])
  end
end
