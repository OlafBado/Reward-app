defmodule RewardAppWeb.UserRewardController do
  use RewardAppWeb, :controller

  alias RewardApp.{UserRewards, Mailer, Email}

  plug RewardAppWeb.RequireAuth
  plug RewardAppWeb.RequireAdmin when action in [:new, :show]

  def index(conn, _parans) do
    user_rewards = UserRewards.get_recent_rewards()
    render(conn, "index.html", user_rewards: user_rewards)
  end

  def send_reward_email(reward_id, user) do
    Email.reward_email(reward_id, user)
    |> Mailer.deliver_later()
  end

  def create(conn, %{"reward_id" => reward_id}) do
    user = conn.assigns.current_user

    case UserRewards.create_user_reward(user, reward_id) do
      {:ok, user_reward} ->
        send_reward_email(user_reward.reward_id, user)

        conn
        |> put_flash(:info, "The reward has been successfully selected.")
        |> redirect(to: Routes.reward_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "You don't have enough points to redeem this reward.")
        |> redirect(to: Routes.reward_path(conn, :index))
    end
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def show(conn, %{"report" => %{"month" => month, "year" => year}} = params) do
    users = UserRewards.generate_report(params)
    IO.inspect(users)

    render(conn, "show.html",
      users: users,
      year: year,
      month: RewardApp.UserRewards.convert_string_to_month(month)
    )
  end
end
