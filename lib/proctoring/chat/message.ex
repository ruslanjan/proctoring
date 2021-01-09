defmodule Proctoring.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  @derive {Jason.Encoder, only: [:id, :is_system, :message, :from, :to_user, :has_image, :image_extension]}
  schema "chat_messages" do
    field :is_system, :boolean, default: false, null: false
    field :message, :string, default: "", null: false
    field :from, :string, size: 64, default: "System"

    field :has_image, :boolean, default: false
    field :image, :binary, default: nil, null: true
    field :image_extension, :string, size: 64, default: nil

    belongs_to :to_user, Proctoring.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:is_system, :message, :from, :to_user_id, :has_image, :image, :image_extension])
    |> foreign_key_constraint(:to_user_id)
    |> validate_required([:is_system, :from])
  end
end
