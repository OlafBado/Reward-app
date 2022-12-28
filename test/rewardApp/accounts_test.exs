defmodule RewardApp.AccountsTest do
  use RewardApp.DataCase, async: true

  alias RewardApp.Accounts
  alias RewardApp.Accounts.User

  @invalid_register_attrs %{name: nil, email: nil, password: nil}
  @register_attrs %{name: "abc", email: "abc@abc", password: "123123123"}

  @email "12@12"
  @password "123123123"

  describe "register_user/1" do
    test "with valid data inserts user" do
      assert {:ok, %User{id: id} = user} = Accounts.register_user(@register_attrs)
      assert user.name == "abc"
      assert user.email == "abc@abc"
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "with invalid data does not insert user" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.register_user(Map.put(@register_attrs, :email, nil))

      assert [] = Accounts.list_users()
    end

    test "requires password to be at least 6 chars long" do
      assert {:error, changeset} =
               Accounts.register_user(Map.put(@register_attrs, :password, "123"))

      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
    end

    test "does not accept same emails" do
      assert {:ok, %User{id: id}} = Accounts.register_user(@register_attrs)
      assert {:error, changeset} = Accounts.register_user(@register_attrs)

      assert %{email: ["has already been taken"]} = errors_on(changeset)
      assert [%User{id: ^id}] = Accounts.list_users()
    end
  end

  describe "list_users/0" do
    test "returns all users" do
      user_fixture()
      assert length(Accounts.list_users()) == 1
    end
  end

  describe "get_user!/1" do
    test "returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "raises if user does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(123)
      end
    end
  end

  describe "create_user/1" do
    test "with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@register_attrs)
      assert user.name == "abc"
      assert user.email == "abc@abc"
      assert user.total_points == 50
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(Map.put(@register_attrs, :name, nil))
    end
  end

  describe "update_user/2" do
    setup do
      {:ok, user: user_fixture()}
    end

    test "with valid data updates the user", %{user: user} do
      assert {:ok, user} = Accounts.update_user(user, %{name: "qwerty"})
      assert user.name == "qwerty"
      assert user.email == "regular@regular"
      assert user.total_points == 50
    end

    test "returns error with invalid data", %{user: user} do
      assert {:error, changeset} = Accounts.update_user(user, %{name: nil, email: nil})
      assert %{email: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error if email is already taken", %{user: user} do
      user2 = user_fixture(%{email: "abc@abc"})
      assert {:error, changeset} = Accounts.update_user(user, %{email: user2.email})
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "with total_points updates user points", %{user: user} do
      assert {:ok, %User{} = user} = Accounts.update_user(user, %{"total_points" => "100"})
      assert user.total_points == 100
    end

    test "returns error if total_points value is blank", %{user: user} do
      assert {:error, changeset} = Accounts.update_user(user, %{"total_points" => ""})
      assert %{total_points: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error if total_points value is negative", %{user: user} do
      assert {:error, changeset} = Accounts.update_user(user, %{"total_points" => "-1"})
      assert %{total_points: ["must be greater than or equal to 0"]} = errors_on(changeset)
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      user = user_fixture()
      assert length(Accounts.list_users()) == 1
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
      assert length(Accounts.list_users()) == 0
    end
  end

  describe "change_user/1" do
    test "returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "change_registration/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = Accounts.change_registration(%User{}, @register_attrs)
    end

    test "returns error with invalid data" do
      changeset = Accounts.change_registration(%User{}, @invalid_register_attrs)

      assert %{email: ["can't be blank"], name: ["can't be blank"], password: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "returns error if password is too short" do
      changeset =
        Accounts.change_registration(%User{}, Map.put(@register_attrs, :password, "123"))

      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
    end
  end

  describe "authenticate_by_email_and_password/2" do
    setup [:register_user_fixture]

    @tag data: %{password: @password}
    test "returns user if password is correct", %{user: user} do
      assert {:ok, auth_user} = Accounts.authenticate_by_email_and_password(user.email, @password)
      assert auth_user.id == user.id
    end

    @tag data: %{password: @password}
    test "returns error if password is wrong", %{user: user} do
      assert {:error, :unauthorized} =
               Accounts.authenticate_by_email_and_password(user.email, "123")
    end

    @tag data: %{password: @password}
    test "returns error if user is not found" do
      assert {:error, :not_found} =
               Accounts.authenticate_by_email_and_password("notfound@notfound", @password)
    end
  end

  describe "validate_points/1" do
    test "returns ok when points are valid" do
      assert {:ok, "2"} = Accounts.validate_points("2")
    end

    test "returns error when points are empty" do
      assert {:error, :empty_points} = Accounts.validate_points("")
    end

    test "returns error when points are negative" do
      assert {:error, :negative_points} = Accounts.validate_points("-2")
    end

    test "returns error when points are equal to 0" do
      assert {:error, :zero_points} = Accounts.validate_points("0")
    end
  end

  describe "send_points/3" do
    setup [:register_user_fixture]

    test "returns ok if sender has enough points and decrement sender's points", %{user: receiver} do
      {_, [{_, sender}]} = register_user_fixture(%{email: "abc@abc"})

      assert {:ok, sender} = Accounts.send_points(sender, receiver.id, "50")
      assert sender.total_points == 0
    end

    test "returns error if sender doesnt' have enough points", %{user: receiver} do
      {_, [{_, sender}]} = register_user_fixture(%{email: "abc@abc"})

      assert {:error, changeset} = Accounts.send_points(sender, receiver.id, "150")
      assert %{total_points: ["must be greater than or equal to 0"]} = errors_on(changeset)
    end
  end

  describe "set_points_monthly/0" do
    test "updates users points" do
      {_, [{_, user1}]} = register_user_fixture(%{email: "abc@abc"})
      {_, [{_, user2}]} = register_user_fixture(%{email: "123@123"})

      {:ok, updated_user1} = Accounts.update_user(user1, %{"total_points" => "100"})
      {:ok, updated_user2} = Accounts.update_user(user2, %{"total_points" => "90"})

      assert updated_user1.total_points == 100
      assert updated_user2.total_points == 90

      assert [ok: %{total_points: user1_points}, ok: %{total_points: user2_points}] =
               Accounts.set_points_monthly()

      assert user1_points == 50
      assert user2_points == 50
    end
  end
end
