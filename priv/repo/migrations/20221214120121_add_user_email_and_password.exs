defmodule RewardApp.Repo.Migrations.AddUserEmailAndPassword do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :string
      add :password_hash, :string
    end

    create unique_index(:users, [:name])
  end
end
