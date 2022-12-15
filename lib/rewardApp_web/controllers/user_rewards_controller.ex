defmodule RewardAppWeb.UserRewardsController do
  use RewardAppWeb, :controller

  def create(conn, params) do
    IO.puts("+++++")
    IO.inspect(params)
    IO.puts("+++++")

    redirect(conn, to: Routes.reward_path(conn, :index))
  end

end
