defmodule RewardApp.Rewards.Reward do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rewards" do
    field :name, :string
    field :price, :integer
    field :description, :string

    many_to_many :users, RewardApp.Accounts.User, join_through: "user_rewards"
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :price, :description])
    |> validate_required([:name, :price, :description])
    |> validate_number(:price, greater_than_or_equal_to: 0, message: "Price can't be negative")
    |> validate_length(:name, min: 2)
  end
end
