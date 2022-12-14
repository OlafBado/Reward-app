defmodule RewardApp.Rewards do
  import Ecto.Query, warn: false

  alias RewardApp.Repo
  alias RewardApp.Rewards.Reward

  @doc """
  Returns the list of rewards.

  ## Examples

      iex> list_rewards()
      [%Reward{}, ...]

  """

  def list_rewards do
    Repo.all(from r in Reward, where: r.deleted == false)
  end

  def get_reward!(id), do: Repo.get!(Reward, id)

  def change_reward(%Reward{} = reward, attrs \\ %{}) do
    Reward.changeset(reward, attrs)
  end

  def create_reward(attrs \\ %{}) do
    %Reward{}
    |> Reward.changeset(attrs)
    |> Repo.insert()
  end

  def update_reward(%Reward{} = reward, attrs) do
    reward
    |> Reward.changeset(attrs)
    |> Repo.update()
  end
end
