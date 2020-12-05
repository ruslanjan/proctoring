defmodule Proctoring.Repo.Migrations.AddRoomId do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :room, :integer, default: 0, null: false
    end
  end
end
