defmodule RewardAppWeb.AuthTest do
  use RewardAppWeb.ConnCase, async: true

  import RewardApp.AccountsFixtures

  alias RewardAppWeb.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(RewardAppWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "login puts user in the session", %{conn: conn} do
    conn =
      conn
      |> Auth.login(user_fixture())
      |> send_resp(200, "")

    assert get_session(conn, :user_id) == conn.assigns.current_user.id
    next_conn = get(conn, "/")
    assert get_session(next_conn, :user_id) == conn.assigns.current_user.id
  end

  test "logout drops session", %{conn: conn} do
    conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(200, "")

    next_conn = get(conn, "/")
    refute get_session(next_conn, :user_id) == 123
  end

  test "call assigns user from session to current_user", %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Auth.init(%{}))

    assert conn.assigns.current_user == user
  end

  test "call with no sesstion assigns current user to nil", %{conn: conn} do
    conn = Auth.call(conn, Auth.init(%{}))

    assert conn.assigns.current_user == nil
  end
end
