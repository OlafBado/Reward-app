defmodule RewardAppWeb.UserControllerTest do
  use RewardAppWeb.ConnCase, async: true

  alias RewardApp.Accounts

  @create_attrs %{name: "some name", email: "some@email", password: "999000999"}

  test "requires user authentication on given actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.user_path(conn, :index)),
        get(conn, Routes.user_path(conn, :show, 1)),
        get(conn, Routes.user_path(conn, :edit, 1)),
        put(conn, Routes.user_path(conn, :update, 1), %{}),
        delete(conn, Routes.user_path(conn, :delete, 1)),
        post(conn, Routes.user_path(conn, :send, 1), %{})
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == Routes.session_path(conn, :new)
        assert conn.halted
      end
    )
  end

  describe "index" do
    setup [:login]

    @tag login_as: %{name: "juri"}
    test "lists all users", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :index))

      assert html_response(conn, 200)
      assert String.contains?(conn.resp_body, user.name)
    end
  end

  describe "new user" do
    test "shows register form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))

      assert html_response(conn, 200)
      assert String.contains?(conn.resp_body, "Register")
    end
  end

  describe "create user" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert id = get_session(conn, :user_id)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert html_response(conn, 200)
      assert String.contains?(conn.resp_body, @create_attrs.name)
    end

    test "renders errors when email is invalid", %{conn: conn} do
      %{assigns: %{changeset: changeset}} =
        conn =
        post(conn, Routes.user_path(conn, :create), user: Map.put(@create_attrs, :email, "abc"))

      assert html_response(conn, 200)

      assert %{email: ["has invalid format"]} == errors_on(changeset)
    end

    test "renders errors when password is invalid", %{conn: conn} do
      %{assigns: %{changeset: changeset}} =
        conn =
        post(conn, Routes.user_path(conn, :create), user: Map.put(@create_attrs, :password, "abc"))

      assert html_response(conn, 200)

      assert %{password: ["should be at least 6 character(s)"]} == errors_on(changeset)
    end

    test "renders errors when name is blank", %{conn: conn} do
      %{assigns: %{changeset: changeset}} =
        conn =
        post(conn, Routes.user_path(conn, :create), user: Map.put(@create_attrs, :name, ""))

      assert html_response(conn, 200)

      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "edit user" do
    setup [:login]

    @tag login_as: %{name: "juri"}
    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))

      assert html_response(conn, 200)
    end

    @tag login_as: %{name: "juri"}
    test "redirects to home page when it's not current user's profile", %{conn: conn} do
      user2 = user_fixture(%{name: "abc", email: "aaa@aaa"})
      conn = get(conn, Routes.user_path(conn, :edit, user2))

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      assert get_flash(conn, :error) ==
               "You must be the owner of this profile to access this page."
    end
  end

  describe "update user" do
    setup [:login]

    @tag login_as: %{name: "juri"}
    test "updates user when data is valid and redirects to show updated profile", %{
      conn: conn,
      user: user
    } do
      conn =
        put(conn, Routes.user_path(conn, :update, user),
          user: Map.drop(@create_attrs, [:password])
        )

      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) == "Profile updated successfully."
    end

    @tag login_as: %{name: "juri"}
    test "renders errors when email is invalid", %{conn: conn, user: user} do
      %{assigns: %{changeset: changeset}} =
        conn =
        put(conn, Routes.user_path(conn, :update, user),
          user: Map.put(@create_attrs, :email, "abc")
        )

      assert html_response(conn, 200)

      assert %{email: ["has invalid format"]} == errors_on(changeset)
    end

    @tag login_as: %{name: "juri"}
    test "renders errors when name is blank", %{conn: conn, user: user} do
      %{assigns: %{changeset: changeset}} =
        conn =
        put(conn, Routes.user_path(conn, :update, user), user: Map.put(@create_attrs, :name, ""))

      assert html_response(conn, 200)

      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "delete user/2" do
    setup [:login]

    @tag login_as: %{name: "juri"}
    test "redirects to home page if it's not user's profile", %{conn: conn} do
      user2 = user_fixture(%{name: "abc", email: "aaa@aaa"})
      conn = delete(conn, Routes.user_path(conn, :delete, user2))
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      assert get_flash(conn, :error) ==
               "You must be the owner of this profile to access this page."
    end

    @tag login_as: %{name: "juri"}
    test "deletes choosen user and redirects to home page", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert get_flash(conn, :info) == "User deleted successfully."
    end
  end

  describe "send/2" do
    setup [:login, :create_user]

    @tag login_as: %{name: "juri"}, attrs: %{name: "abc", email: "aaa@aaa", total_points: 100}
    test "sends points if sender has enough points", %{
      conn: conn,
      user: sender,
      create_user: receiver
    } do
      assert receiver.total_points == 50
      assert sender.total_points == 50
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => "50"}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :info) == "Points sent successfully."
      assert Accounts.get_user!(receiver.id).total_points == 100
      assert Accounts.get_user!(sender.id).total_points == 0
    end

    @tag login_as: %{name: "juri"}, attrs: %{name: "abc", email: "aaa@aaa", total_points: 100}
    test "sends errors if user doesn't have enough points", %{
      conn: conn,
      create_user: receiver
    } do
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => "60"}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) == "You don't have enough points"
    end

    @tag login_as: %{name: "juri"}, attrs: %{name: "abc", email: "aaa@aaa", total_points: 100}
    test "sends errors if user sends 0 points", %{
      conn: conn,
      create_user: receiver
    } do
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => "0"}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) == "must be greater than 0"
    end

    @tag login_as: %{name: "juri"}, attrs: %{name: "abc", email: "aaa@aaa", total_points: 100}
    test "sends errors if user sends negative points", %{
      conn: conn,
      user: sender,
      create_user: receiver
    } do
      conn = Plug.Test.init_test_session(conn, user_id: sender.id)
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => "-1"}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) == "can't be negative"
    end

    @tag login_as: %{name: "juri"}, attrs: %{name: "abc", email: "aaa@aaa", total_points: 100}
    test "sends errors if user sends empty form", %{
      conn: conn,
      user: sender,
      create_user: receiver
    } do
      conn = Plug.Test.init_test_session(conn, user_id: sender.id)
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => ""}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) == "can't be blank"
    end
  end
end
