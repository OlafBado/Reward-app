import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :rewardApp, RewardApp.Repo,
  username: "postgres",
  password: "1234",
  hostname: "localhost",
  database: "reward_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rewardApp, RewardAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "CCvE9LpHbk95RksXfRISOzKa37HcKYJR+sdk5lIW4RZ2GRESWo97Q7vNMWabInxt",
  server: false

# In test we don't send emails.
config :rewardApp, RewardApp.Mailer, adapter: Bamboo.TestAdapter

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :pbkdf2_elixir, :rounds, 1
