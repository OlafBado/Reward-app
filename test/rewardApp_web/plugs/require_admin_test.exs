defmodule RewardAppWeb.RequireAdminTest do
  use RewardAppWeb.ConnCase, async: true

  import RewardApp.AccountsFixtures
  alias RewardAppWeb.RequireAdmin

  setup [:bypass]

  test "halts connection when current user is not an admin", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, user_fixture())
      |> RequireAdmin.call(%{})

    assert conn.halted
  end

  test "user passes through if he is admin", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, user_fixture(%{role: "admin"}))
      |> RequireAdmin.call(%{})

    refute conn.halted
  end
end
