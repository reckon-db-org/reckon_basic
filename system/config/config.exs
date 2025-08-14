# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :basic_app,
  ecto_repos: [BasicApp.Repo]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :basic_app, BasicApp.Mailer, adapter: Swoosh.Adapters.Local

config :basic_app_web,
  ecto_repos: [BasicApp.Repo],
  generators: [context_app: :basic_app]

# Configures the endpoint
config :basic_app_web, BasicAppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: BasicAppWeb.ErrorHTML, json: BasicAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BasicApp.PubSub,
  live_view: [signing_salt: "c8s0mlrC"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  basic_app_web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/basic_app_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  basic_app_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/basic_app_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure ExESDB event store
config :basic_app, :ex_esdb,
  store_id: :basic_app_store,
  data_dir: "/app/data",
  db_type: :cluster,
  description: "BasicApp Event Store",
  tags: "basic_app,phoenix,cluster"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
