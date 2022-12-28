defmodule RewardAppWeb.RequireAuthTest do
  use RewardAppWeb.ConnCase, async: true

  import RewardApp.AccountsFixtures
  alias RewardAppWeb.RequireAuth

  setup [:bypass]

  test "halts connection when no current_user exists", %{conn: conn} do
    conn = RequireAuth.call(conn, %{})
    assert conn.halted
  end

  test "user passes through when current_user is assigned", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, user_fixture())
      |> RequireAuth.call(%{})

    refute conn.halted
  end
end
