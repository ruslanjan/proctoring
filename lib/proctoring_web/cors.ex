defmodule ProctoringWeb.Cors do
  @moduledoc """
  module to support CORS
  """

  @doc """
  Generates `:options` call for router. Needed for CORS.
  ## Examples
      opts post("/login", AuthController, :login)
  will be replaced with to:
      post("/login", AuthController, :login)
      options("/login", AuthController, :options)
  """
  defmacro opts({name, _, args} = fun) do
    quote do
      unquote(fun)
      if unquote(Enum.at(args, 0)) not in @cors_routes do
        @cors_routes @cors_routes ++ [unquote(Enum.at(args, 0))]
        options unquote(Enum.at(args, 0)), unquote(Enum.at(args, 1)), :options

        unquote(
          if name == :resources do
            quote do
              @cors_routes @cors_routes ++ [unquote(Enum.at(args, 0)) <> "/:id"]
              options unquote(Enum.at(args, 0)) <> "/:id", unquote(Enum.at(args, 1)), :options, unquote(Enum.at(args, 2))
            end
          end
        )
      end
    end
  end

  defmacro __using__(_) do
    quote do
      @cors_routes []
      import ProctoringWeb.Cors
    end
  end
end
