defmodule Proctoring.Auth do
  import Ecto.Query, warn: false
  alias Proctoring.Repo

  import Proctoring.Accounts
  alias Proctoring.Accounts.User

  def make_user_auth_token(%User{} = user),
    do: {:ok, Phoenix.Token.sign(ProctoringWeb.Endpoint, "user auth", user.id)}

  def make_user_auth_token(<<user_id::binary>>),
    do: {:ok, Phoenix.Token.sign(ProctoringWeb.Endpoint, "user auth", user_id)}

  def refresh_user_auth_token(token) do
    with {:ok, user_id} <- verify_auth_token(token),
         %User{} = user <- get_user!(user_id),
         {:ok, token} <- make_user_auth_token(user) do
      {:ok, token, user}
    else
      err ->
        err
    end
  end

  def login(_username, nil), do: {:error, :bad_credentials}
  def login(_username, ""), do: {:error, :bad_credentials}
  def login(nil, _password), do: {:error, :bad_credentials}
  def login("", _password), do: {:error, :bad_credentials}

  @doc """
  returns `{:ok, token, user}` if username and password correct.
  """
  @spec login(String.t(), String.t()) :: {:ok, String.t(), User.t()} | {:error, :bad_credentials}
  def login(username, password) do
    with %User{} = user <-
           Repo.get_by(User,
             username: username
           ),
        #  true <- user.can_login,
        #  true <- user.active,
         true <- Argon2.verify_pass(password, user.password),
         {:ok, token} = make_user_auth_token(user) do
      {:ok, token, user}
    else
      _ ->
        {:error, :bad_credentials}
    end
  end

  @doc """
  verifies token.
  if valid returns `{:ok, user_id}`
  else valid returns `{:error, error}`
  """
  def verify_auth_token(token, max_age \\ 86_400) do
    case Phoenix.Token.verify(ProctoringWeb.Endpoint, "user auth", token, max_age: max_age) do
      {:ok, user_id} ->
        {:ok, user_id}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Cleans token and verifyes it. (Cleans from `Bearer`)
  returns tuple `{:ok, user_id}` or `{:error, msg}`
  """
  def parse_auth_token(token) do
    verify_auth_token(clean_auth_token(token))
  end

  def clean_auth_token(token) do
    case String.starts_with?(token, "Bearer ") do
      false ->
        token

      true ->
        List.last(String.split(token, "Bearer "))
    end
  end

  def verify_microsoft_0auth_id_token(token) do

  end
end
