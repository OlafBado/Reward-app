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
    Repo.all(Reward)
  end

  def change_reward(%Reward{} = reward, attrs) do
    Reward.changeset(reward, attrs)
  end

  def create_reward(attrs \\ %{}) do
    %Reward{}
    |> Reward.changeset(attrs)
    |> Repo.insert()
  end
end
