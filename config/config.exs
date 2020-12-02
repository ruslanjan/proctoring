# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :proctoring,
  ecto_repos: [Proctoring.Repo]

# Configures the endpoint
config :proctoring, ProctoringWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NsTgRxgl3XLm3/Uvsz2t5xDaj6+B5wL+qs3aNeuJXa0DtLrw4R8Lnrsi1ORqsbQ1",
  render_errors: [view: ProctoringWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Proctoring.PubSub,
  live_view: [signing_salt: "qFdvl6Xz"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
