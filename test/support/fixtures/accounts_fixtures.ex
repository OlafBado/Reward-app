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
        name: "some name",
        role: "some role",
        total_points: 42
      })
      |> RewardApp.Accounts.create_user()

    user
  end
end
