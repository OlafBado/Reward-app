defmodule RewardApp.Repo.Migrations.AddDefaultRole do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :role, :string, default: "member"
    end
  end
end
