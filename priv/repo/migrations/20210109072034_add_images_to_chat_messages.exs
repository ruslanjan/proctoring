defmodule Proctoring.Repo.Migrations.AddImagesToChatMessages do
  use Ecto.Migration

  def change do
    alter table(:chat_messages) do
      add :has_image, :boolean, default: false
      add :image, :binary, default: nil, null: true
      add :image_extension, :string, size: 64, default: nil, null: true
    end
  end
end
