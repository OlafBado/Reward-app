defmodule RewardApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RewardApp.Repo

  alias RewardApp.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    if attrs["total_points"] do
      user
      |> User.user_points_changeset(attrs)
      |> Repo.update()
    else
      user
      |> User.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user registration changes.

  ## Examples

      iex> rewardApp.Accounts.change_registration(%User{}, %{name: "abc"})
      #Ecto.Changeset<
      action: nil,
      changes: %{name: "abc"},
      errors: [
        password: {"can't be blank", [validation: :required]},
        email: {"can't be blank", [validation: :required]}
      ],
      data: #RewardApp.Accounts.User<>,
      valid?: false
      >

  """

  def change_registration(%User{} = user, params) do
    User.registration_changeset(user, params)
  end

  @doc """
  Returns a `%User{}` and :ok if operation was successfull,
  `%Ecto.Changeset` and :error if failed.

  ## Examples

      iex> RewardApp.Accounts.register_user(%{name: "abc", email: "abc@abc", password: "123123123"})
      {:ok,
      %RewardApp.Accounts.User{
        __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
        id: 3,
        name: "abc",
        email: "abc@abc",
        password: "123123123",
        password_hash: "$pbkdf2-sha512$160000$65PEJHc/q2kui7.kXvCZfw$azHDdqYYeO42OybzF2foyMzqIZ8Gx/9BxSeVc7Lkgm3BtoexvWKwKIrpWJqkyMEGX37ZAL3vLYC5RVspk1dDtQ",
        role: nil,
        total_points: nil,
        inserted_at: ~N[2022-12-14 13:06:38],
        updated_at: ~N[2022-12-14 13:06:38]
      }}

  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Find user by email. If user exists and password is correct,
  than return user and :ok, if user exists and password is incorrect,
  than return :unauthorized, finally if user does not exist, and
  password is incorrect, run additional function to prevent timing attacks

  ## Examples

      iex> RewardApp.Accounts.register_user(%{name: "abc", email: "abc@abc", password: "123123123"})

  """

  def authenticate_by_email_and_password(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Pbkdf2.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  def send_points(sender, receiver_id, points) do
    case User.user_points_changeset(%User{}, %{"total_points" => points}) do
      %Ecto.Changeset{valid?: true} ->
        case update_user(sender, %{
               "total_points" => sender.total_points - String.to_integer(points)
             }) do
          {:ok, user} ->
            update_user(get_user!(receiver_id), %{
              "total_points" => get_user!(receiver_id).total_points + String.to_integer(points)
            })

            {:ok, user}

          {:error, %Ecto.Changeset{valid?: false, errors: [{_, {reason, _}}]}} ->
            {:error, reason}
        end

      %Ecto.Changeset{valid?: false, errors: [{_, {reason, _}}]} ->
        {:error, reason}
    end
  end

  def set_points_monthly do
    for user <- list_users() do
      update_user(user, %{"total_points" => 50})
    end
  end
end
