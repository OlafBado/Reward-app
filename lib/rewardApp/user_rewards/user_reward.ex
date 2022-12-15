defmodule RewardApp.UserRewards.UserReward do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_rewards" do
    field :name, :string
    field :email, :string
    field :reward, :string
    field :cost, :integer

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :reward, :cost])
    |> validate_required([:name, :email, :reward, :cost])
  end
end
