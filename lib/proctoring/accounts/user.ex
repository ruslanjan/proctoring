defmodule Proctoring.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  @derive {Jason.Encoder, only: [:id, :name, :username, :room, :is_proctor, :is_admin]}
  schema "users" do
    field :name, :string
    field :password, :string
    field :username, :string
    field :room, :integer
    field :is_proctor, :boolean, default: false
    field :is_admin, :boolean, default: false

    timestamps()
  end

  def hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password, Argon2.hash_pwd_salt(pass))
      _ ->
        changeset
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :name, :password, :room, :is_proctor, :is_admin])
    |> validate_required([:username, :name, :password, :room, :is_proctor, :is_admin])
    |> validate_length(:username, min: 3)
    |> unique_constraint(:username)
    |> hash_password()
  end
end
