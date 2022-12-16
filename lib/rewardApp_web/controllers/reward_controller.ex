defmodule RewardAppWeb.RewardController do
  use RewardAppWeb, :controller

  alias RewardApp.Rewards
  alias RewardApp.Rewards.Reward

  plug RewardAppWeb.RequireAuth when action in [:index, :new, :create, :edit, :update]
  plug RewardAppWeb.RequireAdmin when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    rewards = Rewards.list_rewards()
    render(conn, "index.html", rewards: rewards)
  end

  def new(conn, _params) do
    changeset = Rewards.change_reward(%Reward{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"reward" => reward_params}) do
    case Rewards.create_reward(reward_params) do
      {:ok, _reward} ->
        conn
        |> put_flash(:info, "Reward created successfully.")
        |> redirect(to: Routes.reward_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    reward = Rewards.get_reward!(id)
    changeset = Rewards.change_reward(reward)
    render(conn, "edit.html", reward: reward, changeset: changeset)
  end

  def update(conn, %{"id" => id, "reward" => reward_params}) do
    reward = Rewards.get_reward!(id)
    case Rewards.update_reward(reward, reward_params) do
      {:ok, _reward} ->
        conn
        |> put_flash(:info, "Reward updated successfully.")
        |> redirect(to: Routes.reward_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> render("edit.html", reward: reward, changeset: changeset)
    end
  end
end
