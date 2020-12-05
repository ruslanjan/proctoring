defmodule ProctoringWeb.Router do
  use ProctoringWeb, :router

  import ProctoringWeb.Cors

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ProctoringWeb.Plugs.Cors, []
    plug ProctoringWeb.AuthenticationPlug, []
  end

  pipeline :require_auth do
    plug ProctoringWeb.RequireAuthenticationPlug, []
  end

  scope "/", ProctoringWeb do
    pipe_through :browser

    # get "/", PageController, :index
    get "/", CallController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ProctoringWeb do
    pipe_through :api

    opts(post "/login", AuthController, :login)

    pipe_through :require_auth
    opts(post "/refresh_token", AuthController, :refresh_token)
    opts(resources "/users", UserController, except: [:new, :edit])
    opts(get "/users/room/:room", UserController, :list_users_in_room)
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ProctoringWeb.Telemetry
    end
  end
end
