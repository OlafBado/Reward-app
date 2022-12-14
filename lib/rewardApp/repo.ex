defmodule RewardApp.Repo do
  use Ecto.Repo,
    otp_app: :rewardApp,
    adapter: Ecto.Adapters.Postgres
end
