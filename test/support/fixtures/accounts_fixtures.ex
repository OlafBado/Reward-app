defmodule RewardApp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RewardApp.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "regular",
        role: "member",
        email: "regular@regular"
      })
      |> RewardApp.Accounts.create_user()

    user
  end
end
