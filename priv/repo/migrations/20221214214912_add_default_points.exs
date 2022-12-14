defmodule RewardApp.Repo.Migrations.AddDefaultPoints do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :total_points, :integer, default: 50
    end
  end
end
