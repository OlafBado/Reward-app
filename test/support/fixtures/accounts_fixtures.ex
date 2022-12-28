defmodule RewardApp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RewardApp.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  import Plug.Conn
  alias RewardApp.Accounts

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "regular",
        role: "member",
        email: "regular@regular"
      })
      |> Accounts.create_user()

    user
  end

  def login(%{conn: conn, login_as: data}) do
    user = user_fixture(data)
    conn = assign(conn, :current_user, user)

    {:ok, conn: conn, user: user}
  end

  def register_user_fixture(attrs) do
    {_, user} =
      attrs
      |> Enum.into(%{
        name: "regular",
        email: "regular@regular",
        password: "123123123"
      })
      |> Accounts.register_user()

    {:ok, user: user}
  end
end
