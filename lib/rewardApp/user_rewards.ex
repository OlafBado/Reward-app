defmodule RewardApp.UserRewards do
  import Ecto.Query, warn: false

  alias RewardApp.{Repo, Accounts, Rewards}
  alias RewardApp.UserRewards.UserReward

  def list_user_rewards do
    Repo.all(UserReward)
  end

  def get_recent_rewards do
    user_rewards = list_user_rewards()

    for user_reward <- user_rewards do
      user_name = Accounts.get_user!(user_reward.user_id).name
      reward_name = Rewards.get_reward!(user_reward.reward_id).name

      %{
        user_name: user_name,
        reward_name: reward_name,
        inserted_at: user_reward.inserted_at
      }
    end
  end

  def create_user_reward(user, reward_id \\ %{}) do
    reward = Rewards.get_reward!(reward_id)

    case Accounts.update_user(user, %{"total_points" => user.total_points - reward.price}) do
      {:ok, _user} ->
        %UserReward{}
        |> UserReward.changeset(%{user_id: user.id, reward_id: reward.id})
        |> Repo.insert()

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def create_naive_date(year, month, day) do
    case NaiveDateTime.new(year, month, day, 0, 0, 0) do
      {:ok, naive_date} -> {:ok, naive_date}
      {:error, :invalid_date} -> {:error, :invalid_date}
    end
  end

  def create_date_range(year, month) do
    with {:ok, start_date} <- create_naive_date(year, month, 1),
         end_of_month <- Date.end_of_month(start_date),
         {:ok, end_date} <-
           create_naive_date(end_of_month.year, end_of_month.month, end_of_month.day),
         end_date <- NaiveDateTime.add(end_date, 86399) do
      {start_date, end_date}
    else
      {:error, _} -> {:error, :invalid_date}
    end
  end

  def create_query({start_date, end_date}) do
    from u in Accounts.User,
      left_join: ur in UserReward,
      on: ur.user_id == u.id,
      left_join: r in Rewards.Reward,
      on:
        r.id == ur.reward_id and
          fragment("? BETWEEN ? AND ?", ur.inserted_at, ^start_date, ^end_date),
      select: %{name: u.name, reward: r.name}
  end

  def check_for_nil(list) do
    Enum.any?(list, fn %{reward: value} -> value == nil end)
  end

  def group_list(list) do
    list
    |> Enum.group_by(fn %{name: name} -> name end)
    |> Enum.map(fn {name, values} ->
      case check_for_nil(values) do
        true -> %{name: name, reward: []}
        _ -> %{name: name, reward: Enum.map(values, fn %{reward: reward} -> reward end)}
      end
    end)
  end

  def generate_report(%{"report" => %{"month" => month, "year" => year}}) do
    create_date_range(String.to_integer(year), String.to_integer(month))
    |> create_query
    |> Repo.all()
    |> group_list
  end

  def convert_string_to_month(string) do
    case string do
      "1" -> "January"
      "2" -> "February"
      "3" -> "March"
      "4" -> "April"
      "5" -> "May"
      "6" -> "June"
      "7" -> "July"
      "8" -> "August"
      "9" -> "September"
      "10" -> "October"
      "11" -> "November"
      "12" -> "December"
      _ -> {:error, :invalid_month}
    end
  end
end
