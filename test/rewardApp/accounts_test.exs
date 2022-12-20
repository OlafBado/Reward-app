defmodule RewardApp.AccountsTest do
  use RewardApp.DataCase

  alias RewardApp.Accounts

  describe "users" do
    alias RewardApp.Accounts.User

    import RewardApp.AccountsFixtures

    @invalid_attrs %{name: nil, role: nil, total_points: nil}
    @valid_attrs %{name: "some updated name", role: "some updated role", email: "12@12"}
    @valid_register_attrs %{
      name: "some updated name",
      role: "some updated role",
      email: "12@12",
      password: "123123123"
    }
    @invalid_register_attrs %{
      name: "some updated name",
      role: "some updated role",
      email: "12@12",
      password: "123"
    }

    test "list_users/0 returns all users" do
      user_fixture()
      assert length(Accounts.list_users()) == 1
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == "some updated name"
      assert user.role == "some updated role"
      assert user.email == "12@12"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      assert {:ok, %User{} = user} = Accounts.update_user(user, @valid_attrs)
      assert user.name == "some updated name"
      assert user.role == "some updated role"
      assert user.email == "12@12"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "update_user/2 with total_points updates user points" do
      user = user_fixture()
      update_attrs = %{"total_points" => "100"}
      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)

      assert user.total_points == 100
    end

    test "change_registration/2 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_registration(user, @valid_attrs)
    end

    test "change_registration/2 returns an error if password is too short" do
      user = user_fixture()
      result = Accounts.change_registration(user, @invalid_register_attrs)
      {error, _rest} = result.errors[:password]
      assert %Ecto.Changeset{} = result
      assert error == "should be at least %{count} character(s)"
    end

    test "register_user/1 inserts user to db with valid data" do
      result = Accounts.register_user(@valid_register_attrs)

      assert {:ok, %User{} = user} = result
      assert user.name == "some updated name"
      assert user.role == "some updated role"
      assert user.email == "12@12"
      assert user.password == "123123123"
      assert user.password_hash != nil
    end

    test "authenticate_by_email_and_password/2 returns ok and user if password is correct" do
      {_, user} = Accounts.register_user(@valid_register_attrs)

      assert {:ok, %User{}} = Accounts.authenticate_by_email_and_password(user.email, "123123123")
    end

    test "authenticate_by_email_and_password/2 returns error when password is wrong" do
      {_, user} = Accounts.register_user(@valid_register_attrs)

      assert {:error, :unauthorized} =
               Accounts.authenticate_by_email_and_password(user.email, "111111111")
    end

    test "authenticate_by_email_and_password/2 returns error when user not found" do
      assert {:error, :not_found} =
               Accounts.authenticate_by_email_and_password("example@abc", "111111111")
    end

    test "validate_points/1 error when points are empty" do
      assert {:error, :empty_points} = Accounts.validate_points("")
    end

    test "validate_points/1 error when points are negative" do
      assert {:error, :negative_points} = Accounts.validate_points("-2")
    end

    test "validate_points/1 error when points are equal to 0" do
      assert {:error, :zero_points} = Accounts.validate_points("0")
    end

    test "send_points/3 returns ok if user has enough points" do
      {_, user} = Accounts.register_user(@valid_register_attrs)
      {_, user2} = Accounts.register_user(@valid_register_attrs)

      IO.inspect(user)
    end
  end
end
