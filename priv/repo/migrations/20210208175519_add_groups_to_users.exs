defmodule Proctoring.Repo.Migrations.AddGroupsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :group, :string, default: "", null: false
    end
    alter table(:chat_messages) do
      add :group, :string, default: "", null: false
    end
  end
end
