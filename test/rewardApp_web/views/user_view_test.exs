defmodule RewardAppWeb.UserViewTest do
  use RewardAppWeb.ConnCase, async: true
  import Phoenix.View
  import RewardApp.AccountsFixtures
  alias RewardAppWeb.UserView
  alias RewardApp.Accounts.User
  alias RewardApp.Accounts

  setup %{conn: conn} do
    user = user_fixture(%{email: "main@main", name: "main"})
    conn = assign(conn, :current_user, user)
    {:ok, conn: conn, current_user: user}
  end

  test "renders edit.html", %{conn: conn, current_user: current_user} do
    changeset = Accounts.change_user(current_user)

    content =
      render_to_string(
        UserView,
        "edit.html",
        conn: conn,
        user: current_user,
        changeset: changeset,
        current_user: current_user
      )

    assert String.contains?(content, "Edit profile")
    assert String.contains?(content, current_user.name)
    assert String.contains?(content, current_user.email)
  end

  test "renders form.html", %{conn: conn} do
    changeset = Accounts.change_registration(%User{}, %{})

    content =
      render_to_string(
        UserView,
        "form.html",
        conn: conn,
        action: "edit",
        changeset: changeset
      )

    assert String.contains?(content, "Register")
  end

  test "renders index.html", %{conn: conn, current_user: current_user} do
    users = [user_fixture(%{email: "abc@abc"}), user_fixture(%{email: "123@123"})]

    content =
      render_to_string(
        UserView,
        "index.html",
        conn: conn,
        users: users,
        current_user: current_user
      )

    assert String.contains?(content, "Users")

    for user <- users do
      assert String.contains?(content, user.name)
    end

    refute String.contains?(content, current_user.name)
  end

  test "renders new.html", %{conn: conn} do
    changeset = Accounts.change_registration(%User{}, %{})

    content =
      render_to_string(
        UserView,
        "new.html",
        conn: conn,
        changeset: changeset
      )

    assert String.contains?(content, "Register")
  end

  test "renders show.html", %{conn: conn, current_user: current_user} do
    content =
      render_to_string(
        UserView,
        "show.html",
        conn: conn,
        user: current_user,
        current_user: current_user
      )

    assert String.contains?(content, current_user.name)
    assert String.contains?(content, current_user.email)
  end
end
