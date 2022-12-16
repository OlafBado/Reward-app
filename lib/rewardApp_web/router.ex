defmodule RewardAppWeb.Router do
  use RewardAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {RewardAppWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RewardAppWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RewardAppWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/user", RewardAppWeb do
    pipe_through :browser

    get "/", UserController, :index
    post "/", UserController, :create
    get "/new", UserController, :new
    get "/:id", UserController, :show
    get "/:id/edit", UserController, :edit
    put "/:id", UserController, :update
    delete "/:id", UserController, :delete
    post "/:id", UserController, :send
  end

  scope "/sessions", RewardAppWeb do
    pipe_through :browser

    get "/new", SessionController, :new
    post "/", SessionController, :create
    delete "/:id", SessionController, :delete
  end

  scope "/rewards", RewardAppWeb do
    pipe_through :browser

    get "/", RewardController, :index
    get "/new", RewardController, :new
    post "/", RewardController, :create
    get "/:id/edit", RewardController, :edit
    put "/:id", RewardController, :update
  end

  scope "/user_rewards", RewardAppWeb do
    pipe_through :browser

    get "/", UserRewardController, :index
    post "/", UserRewardController, :create
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

      live_dashboard "/dashboard", metrics: RewardAppWeb.Telemetry
    end

  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
