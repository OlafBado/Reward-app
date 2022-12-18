defmodule RewardAppWeb.UserRewardController do
  use RewardAppWeb, :controller

  alias RewardApp.{UserRewards, Mailer, Email}
  # alias RewardAppWeb.Emails.RewardEmail

  def index(conn, _parans) do
    user_rewards = UserRewards.list_user_rewards
    render(conn, "index.html", user_rewards: user_rewards)
  end

  def send_reward_email(user_reward, user) do
    Email.reward_email(user_reward, user)
    |> Mailer.deliver_later()
  end

  def create(conn, %{"reward_id" => reward_id}) do
    user = conn.assigns.current_user

    case UserRewards.create_user_reward(user, reward_id) do
      {:ok, user_reward} ->
        send_reward_email(user_reward, user)
        conn
        |> put_flash(:info, "The reward has been successfully selected.")
        |> redirect(to: Routes.reward_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "You don't have enough points to redeem this reward.")
        |> redirect(to: Routes.reward_path(conn, :index))
    end
  end

end
