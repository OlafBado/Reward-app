defmodule RewardApp.AccountsTest do
  use RewardApp.DataCase, async: true

  import RewardApp.AccountsFixtures

  alias RewardApp.Accounts
  alias RewardApp.Accounts.User

  @invalid_attrs %{name: nil, role: nil, total_points: nil}
  @valid_attrs %{name: "some updated name", role: "some updated role", email: "12@12"}
  @email "12@12"
  @password "123123123"

  describe "users" do
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
      assert user.total_points == 50
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
      assert user.total_points == 50
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
      assert {:ok, %User{} = user} = Accounts.update_user(user, %{"total_points" => "100"})
      assert user.total_points == 100
    end

    test "change_registration/2 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_registration(user, @valid_attrs)
    end

    test "change_registration/2 returns an error if password is too short" do
      user = user_fixture()
      result = Accounts.change_registration(user, Map.put(@valid_attrs, :password, "123"))
      {error, _rest} = result.errors[:password]
      assert %Ecto.Changeset{} = result
      assert error == "should be at least %{count} character(s)"
    end

    test "register_user/1 inserts user to db with valid data" do
      result = Accounts.register_user(Map.put(@valid_attrs, :password, "999000999"))

      assert {:ok, %User{} = user} = result
      assert user.name == "some updated name"
      assert user.role == "some updated role"
      assert user.email == "12@12"
      assert user.password == "999000999"
      assert user.password_hash != nil
    end

    test "authenticate_by_email_and_password/2 returns ok and user if password is correct" do
      {_, user} = Accounts.register_user(Map.put(@valid_attrs, :password, "999000999"))

      assert {:ok, %User{}} = Accounts.authenticate_by_email_and_password(user.email, "999000999")
    end

    test "authenticate_by_email_and_password/2 returns error when password is wrong" do
      {_, _user} = Accounts.register_user(Map.put(@valid_attrs, :password, "999000999"))

      assert {:error, :unauthorized} = Accounts.authenticate_by_email_and_password(@email, "123")
    end

    test "authenticate_by_email_and_password/2 returns error when user not found" do
      assert {:error, :not_found} = Accounts.authenticate_by_email_and_password(@email, @password)
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

    test "send_points/3 returns ok if sender has enough points and decrement sender's points" do
      {_, sender} = Accounts.register_user(Map.put(@valid_attrs, :password, "999000999"))

      {_, receiver} =
        Accounts.register_user(
          Map.replace(Map.put(@valid_attrs, :password, "999000888"), :email, "acd@acd")
        )

      assert {:ok, user} = Accounts.send_points(sender, receiver.id, "50")
      assert user.total_points == 0
    end

    test "send_points/3 returns error if sender doesnt' have enough points" do
      {_, sender} = Accounts.register_user(Map.put(@valid_attrs, :password, "999000999"))

      {_, receiver} =
        Accounts.register_user(
          Map.replace(Map.put(@valid_attrs, :password, "999000888"), :email, "acd@acd")
        )

      assert {:error, %Ecto.Changeset{errors: [total_points: {error, _rest}]}} =
               Accounts.send_points(sender, receiver.id, "150")

      assert error == "must be greater than or equal to %{number}"
    end

    test "set_points_monthly updates users points" do
      {_, user1} = Accounts.register_user(Map.put(@valid_attrs, :password, "999000999"))

      {_, user2} =
        Accounts.register_user(
          Map.replace(Map.put(@valid_attrs, :password, "999000888"), :email, "acd@acd")
        )

      {:ok, %User{} = updated_user1} = Accounts.update_user(user1, %{"total_points" => "100"})
      {:ok, %User{} = updated_user2} = Accounts.update_user(user2, %{"total_points" => "90"})

      assert updated_user1.total_points == 100
      assert updated_user2.total_points == 90

      assert [ok: %{total_points: user1_points}, ok: %{total_points: user2_points}] =
               Accounts.set_points_monthly()

      assert user1_points == 50
      assert user2_points == 50
    end
  end
end
