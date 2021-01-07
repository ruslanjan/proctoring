defmodule Proctoring.Repo.Migrations.AddChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :is_system, :boolean, default: false, null: false
      add :message, :text, default: "", null: false
      add :from, :string, size: 64, default: "System"
      add :to_user_id, references(:users, on_delete: :nothing), null: true

      timestamps()
    end
  end
end
