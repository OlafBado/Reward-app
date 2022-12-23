defmodule RewardApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :role, :string, default: "member"
    field :total_points, :integer, default: 50

    many_to_many :rewards, RewardApp.Rewards.Reward, join_through: "user_rewards"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :role])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 2)
    |> unique_constraint(:email)
  end

  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 50)
    |> put_pass_hash()
  end

  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end

  def user_points_changeset(user, points) do
    user
    |> cast(points, [:total_points, :role])
    |> validate_required([:total_points])
    |> validate_points(points)
    |> validate_number(:total_points, greater_than_or_equal_to: 0)
  end

  defp validate_points(changeset, %{"total_points" => points}) do
    if points == "" do
      add_error(changeset, :total_points, "can't be blank")
    else
      changeset
    end
  end
end
