defmodule RewardApp.Scheduler do
  use Quantum, otp_app: :rewardApp

  def update_database do
    RewardApp.Accounts.set_points_monthly
  end
end
