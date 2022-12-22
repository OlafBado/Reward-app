defmodule RewardAppWeb.UserControllerTest do
  use RewardAppWeb.ConnCase, async: true
  import RewardApp.AccountsFixtures

  @create_attrs %{name: "some name", email: "some@email", password: "999000999"}

  describe "index" do
    setup [:create_user]

    test "lists all users when user is signed in", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.user_path(conn, :index))

      assert html_response(conn, 200)
    end

    test "redirects to log in page when not signed in", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "new user" do
    test "shows register form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))

      assert html_response(conn, 200)
    end
  end

  describe "create user" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert id = get_session(conn, :user_id)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert html_response(conn, 200)
    end

    test "renders errors when email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :create), user: Map.put(@create_attrs, :email, "abc"))

      assert html_response(conn, 200)

      assert conn.assigns.changeset.errors[:email] ==
               {"has invalid format", [validation: :format]}
    end

    test "renders errors when password is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :create), user: Map.put(@create_attrs, :password, "abc"))

      assert html_response(conn, 200)

      assert conn.assigns.changeset.errors[:password] ==
               {"should be at least %{count} character(s)",
                [
                  count: 6,
                  validation: :length,
                  kind: :min,
                  type: :string
                ]}
    end

    test "renders errors when name is blank", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: Map.put(@create_attrs, :name, ""))
      assert html_response(conn, 200)

      assert conn.assigns.changeset.errors[:name] ==
               {"can't be blank",
                [
                  validation: :required
                ]}
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user when logged in", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.user_path(conn, :edit, user))

      assert html_response(conn, 200)
    end

    test "redirects to log in page when not logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))

      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert html_response(conn, 302)
    end

    test "redirects to home page when it's not current user's profile", %{conn: conn, user: user} do
      user2 = user_fixture(%{name: "abc", email: "aaa@aaa"})
      conn = Plug.Test.init_test_session(conn, user_id: user2.id)
      conn = get(conn, Routes.user_path(conn, :edit, user))

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      assert get_flash(conn, :error) ==
               "You must be the owner of this profile to access this page."
    end
  end

  describe "update user" do
    setup [:create_user]

    test "updates user when data is valid and redirects to show updated profile", %{
      conn: conn,
      user: user
    } do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)

      conn =
        put(conn, Routes.user_path(conn, :update, user),
          user: Map.drop(@create_attrs, [:password])
        )

      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) == "Profile updated successfully."
      conn = get(conn, Routes.user_path(conn, :show, user))

      assert html_response(conn, 200)
    end

    test "redirects to log in page when user is not logged in", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: user)

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "renders errors when email is invalid", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)

      conn =
        put(conn, Routes.user_path(conn, :update, user),
          user: Map.put(@create_attrs, :email, "abc")
        )

      assert html_response(conn, 200)

      assert conn.assigns.changeset.errors[:email] ==
               {"has invalid format", [validation: :format]}
    end

    test "renders errors when name is blank", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)

      conn =
        put(conn, Routes.user_path(conn, :update, user), user: Map.put(@create_attrs, :name, ""))

      assert html_response(conn, 200)

      assert conn.assigns.changeset.errors[:name] ==
               {"can't be blank",
                [
                  validation: :required
                ]}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "redirects to log in page if user is not logged in", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "redirects to home page if it's not user's profile", %{conn: conn, user: user} do
      user2 = user_fixture(%{name: "abc", email: "aaa@aaa"})
      conn = Plug.Test.init_test_session(conn, user_id: user2.id)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.page_path(conn, :index)

      assert get_flash(conn, :error) ==
               "You must be the owner of this profile to access this page."
    end

    test "deletes chosen user and redirects to home page", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert get_flash(conn, :info) == "User deleted successfully."
    end
  end

  describe "send" do
    setup [:create_user]

    test "redirects to log in page if user is not logged in", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_path(conn, :send, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "sends points if sender has enough points", %{
      conn: conn,
      user: sender
    } do
      receiver = user_fixture(%{name: "abc", email: "aaa@aaa", total_points: 100})

      conn = Plug.Test.init_test_session(conn, user_id: sender.id)
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => "50"}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :info) == "Points sent successfully."
    end

    test "sends errors if user doesn't have enough points", %{
      conn: conn,
      user: sender
    } do
      receiver = user_fixture(%{name: "abc", email: "aaa@aaa"})

      conn = Plug.Test.init_test_session(conn, user_id: sender.id)
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => "60"}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) == "You do not have enough points to send."
    end

    test "sends errors if user sends 0 points", %{
      conn: conn,
      user: sender
    } do
      receiver = user_fixture(%{name: "abc", email: "aaa@aaa", total_points: 100})

      conn = Plug.Test.init_test_session(conn, user_id: sender.id)
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => "0"}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) == "You must send at least 1 point."
    end

    test "sends errors if user sends negative points", %{
      conn: conn,
      user: sender
    } do
      receiver = user_fixture(%{name: "abc", email: "aaa@aaa", total_points: 100})

      conn = Plug.Test.init_test_session(conn, user_id: sender.id)
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => "-1"}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) == "You cannot send negative points."
    end

    test "sends errors if user sends empty form", %{
      conn: conn,
      user: sender
    } do
      receiver = user_fixture(%{name: "abc", email: "aaa@aaa", total_points: 100})

      conn = Plug.Test.init_test_session(conn, user_id: sender.id)
      conn = post(conn, Routes.user_path(conn, :send, receiver), %{"user" => %{"points" => ""}})

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) == "You must enter a number of points to send."
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
