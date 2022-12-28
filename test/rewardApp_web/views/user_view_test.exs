defmodule RewardAppWeb.UserViewTest do
  use RewardAppWeb.ConnCase, async: true
  import Phoenix.View

  alias RewardAppWeb.UserView
  alias RewardApp.Accounts.User
  alias RewardApp.Accounts

  setup [:login]

  @tag login_as: %{name: "juri"}
  test "renders edit.html", %{conn: conn, user: user} do
    changeset = Accounts.change_user(user)

    content =
      render_to_string(
        UserView,
        "edit.html",
        conn: conn,
        user: user,
        changeset: changeset,
        current_user: user
      )

    assert String.contains?(content, "Edit profile")
    assert String.contains?(content, user.name)
    assert String.contains?(content, user.email)
  end

  @tag login_as: %{name: "juri"}
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

  @tag login_as: %{name: "juri"}
  test "renders index.html", %{conn: conn, user: user} do
    users = [user_fixture(%{email: "abc@abc"}), user_fixture(%{email: "123@123"})]

    content =
      render_to_string(
        UserView,
        "index.html",
        conn: conn,
        users: users,
        current_user: user
      )

    assert String.contains?(content, "Users")

    for user <- users do
      assert String.contains?(content, user.name)
    end

    refute String.contains?(content, user.name)
  end

  @tag login_as: %{name: "juri"}
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

  @tag login_as: %{name: "juri"}
  test "renders show.html", %{conn: conn, user: user} do
    content =
      render_to_string(
        UserView,
        "show.html",
        conn: conn,
        user: user,
        current_user: user
      )

    assert String.contains?(content, user.name)
    assert String.contains?(content, user.email)
  end
end
