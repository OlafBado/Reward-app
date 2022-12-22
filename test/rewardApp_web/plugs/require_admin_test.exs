defmodule RewardAppWeb.RequireAdminTest do
  use RewardAppWeb.ConnCase, async: true

  import RewardApp.AccountsFixtures
  alias RewardAppWeb.RequireAdmin

  describe "call" do
    test "redirects to home page if user is not an admin", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> Plug.Test.init_test_session(user_id: user.id)
        |> with_pipeline()
        |> RequireAdmin.call(%{})

      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :error) == "You must be an admin to access this page."
    end

    test "renders form for new reward if user is an admin", %{conn: conn} do
      user = user_fixture(%{role: "admin"})

      conn =
        conn
        |> Plug.Test.init_test_session(user_id: user.id)
        |> with_pipeline()
        |> RequireAdmin.call(%{})

      assert conn.status != 302
    end
  end

  defp with_pipeline(conn) do
    conn
    |> bypass_through(RewardAppWeb.Router, :browser)
    |> get(Routes.reward_path(conn, :new))
  end
end
