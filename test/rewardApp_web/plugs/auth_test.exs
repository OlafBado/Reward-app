defmodule RewardAppWeb.AuthTest do
  use RewardAppWeb.ConnCase, async: true

  import RewardApp.AccountsFixtures

  alias RewardAppWeb.Auth

  describe "call" do
    test "assign nil if no user_id in session", %{conn: conn} do
      conn =
        conn
        |> with_pipeline()

      assert get_session(conn, :user_id) == nil
      assert conn.assigns[:current_user] == nil
    end

    test "assign nil if user_id in session but user not found in database", %{conn: conn} do
      conn =
        conn
        |> with_pipeline()
        |> put_session(:user_id, 123)

      assert get_session(conn, :user_id) == 123
      assert conn.assigns[:current_user] == nil
    end

    test "assigns user if user_id in session and user in database", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> Plug.Test.init_test_session(user_id: user.id)
        |> with_pipeline()

      assert get_session(conn, :user_id) == user.id
      assert conn.assigns[:current_user] == user
    end
  end

  describe "login" do
    test "assigns user to current_user and sets session", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> with_pipeline()
        |> Auth.login(user)

      assert get_session(conn, :user_id) == user.id
      assert conn.assigns[:current_user] == user
    end
  end

  describe "logout" do
    test "drops session", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> Plug.Test.init_test_session(user_id: user.id)
        |> with_pipeline()
        |> Auth.logout()
        |> get(Routes.user_path(conn, :index))

      assert get_session(conn, :user_id) == nil
      assert conn.assigns[:current_user] == nil
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end
  end

  defp with_pipeline(conn) do
    conn
    |> bypass_through(RewardAppWeb.Router, :browser)
    |> get(Routes.user_path(conn, :index))
  end
end
