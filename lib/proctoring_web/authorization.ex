defmodule ProctoringWeb.Authorization do
  defmodule ForbiddenError do
    @moduledoc """
    Exception raised when no route is found.
    """
    defexception plug_status: 403, message: "resource forbidden", conn: nil, router: nil

    # def exception(opts) do
    #   conn = Keyword.fetch!(opts, :conn)
    #   router = Keyword.fetch!(opts, :router)
    #   path = "/" <> Enum.join(conn.path_info, "/")

    #   %ForbiddenError{
    #     message: "resource forbidden #{conn.method} #{path} (#{inspect(router)})",
    #     conn: conn,
    #     router: router
    #   }
    # end
  end

  import Plug.Conn

  alias Proctoring.Accounts.User

  @doc """
  Check if current user can do action
  """
  def can?(conn, action) do
    case action.(conn) do
      true ->
        true
      false ->
        raise ForbiddenError
    end
  end

  def create?(Proctoring.Accounts.User) do
    fn conn ->
      with %User{} = user <- conn.assigns[:current_user],
         true <- user != nil,
         true <- user.is_admin do
          true
      else
        _ ->
          false
      end
    end
  end

  def create?(Proctoring.Chat.Message) do
    fn conn ->
      with %User{} = user <- conn.assigns[:current_user],
         true <- user != nil,
         true <- user.is_admin or user.is_proctor do
          true
      else
        _ ->
          false
      end
    end
  end

  def delete?(Proctoring.Accounts.User) do
    fn conn ->
      with %User{} = user <- conn.assigns[:current_user],
         true <- user != nil,
         true <- user.is_admin do
          true
      else
        _ ->
          false
      end
    end
  end

  def update?(Proctoring.Accounts.User) do
    fn conn ->
      with %User{} = user <- conn.assigns[:current_user],
         true <- user != nil,
         true <- user.is_admin do
          true
      else
        _ ->
          false
      end
    end
  end

  def view?(Proctoring.Accounts.User) do
    fn conn ->
      with %User{} = user <- conn.assigns[:current_user],
         true <- user != nil do
          true
      else
        _ ->
          false
      end
    end
  end

  def view?(Proctoring.Chat.Message) do
    fn conn ->
      with %User{} = user <- conn.assigns[:current_user],
         true <- user != nil,
         true <- user.is_admin or user.is_proctor do
          true
      else
        _ ->
          false
      end
    end
  end
end
