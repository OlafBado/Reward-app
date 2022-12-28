defmodule RewardApp.PlugsFixtures do
  import Phoenix.ConnTest

  @endpoint RewardAppWeb.Endpoint

  def bypass(%{conn: conn}) do
    conn =
      conn
      |> bypass_through(RewardAppWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end
end
