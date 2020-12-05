defmodule Proctoring.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :name, :string
      add :password, :string
      add :is_proctor, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:users, [:username])

  end
end
