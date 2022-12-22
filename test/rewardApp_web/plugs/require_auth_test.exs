defmodule RewardAppWeb.RequireAuthTest do
  use RewardAppWeb.ConnCase, async: true

  import RewardApp.AccountsFixtures
  alias RewardAppWeb.RequireAuth

  describe "call" do
    test "redirects to log in page when user is not logged in", %{conn: conn} do
      conn =
        conn
        |> bypass_through(RewardAppWeb.Router, :browser)
        |> with_pipeline()
        |> RequireAuth.call(%{})

      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "user passes through when current_user is assigned", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> Plug.Test.init_test_session(user_id: user.id)
        |> with_pipeline()
        |> RequireAuth.call(%{})

      assert conn.assigns[:current_user] == user
      assert conn.status != 302
    end
  end

  defp with_pipeline(conn) do
    conn
    |> bypass_through(RewardAppWeb.Router, :browser)
    |> get(Routes.user_path(conn, :index))
  end
end
