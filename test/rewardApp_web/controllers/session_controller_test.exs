defmodule RewardAppWeb.SessionControllerTest do
  use RewardAppWeb.ConnCase, async: true

  @valid_login_attrs %{"session" => %{"email" => "uid@uid", "password" => "888777666"}}

  describe "new" do
    test "renders log in form", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))
      assert html_response(conn, 200)
    end
  end

  describe "create" do
    setup [:register_user_fixture]

    test "redirects to user index page when logged in successfully", %{
      conn: conn,
      user: %{email: email, password: password}
    } do
      conn =
        post(conn, Routes.session_path(conn, :create), %{
          "session" => %{"email" => email, "password" => password}
        })

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :info) == "Welcome back!"
    end

    test "renders log in form with error when email is invalid", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.session_path(conn, :create),
          put_in(@valid_login_attrs, ["session", "email"], "uidabc")
        )

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Invalid email or password."
    end

    test "renders log in form with error when password is invalid", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.session_path(conn, :create),
          put_in(@valid_login_attrs, ["session", "password"], "123")
        )

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Invalid email or password."
    end
  end

  describe "delete" do
    setup [:register_user_fixture]

    test "redirects to log in page when logged out successfully", %{conn: conn, user: user} do
      conn = post(conn, Routes.session_path(conn, :create), @valid_login_attrs)
      conn = delete(conn, Routes.session_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end
end
