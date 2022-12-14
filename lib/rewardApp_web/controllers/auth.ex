defmodule RewardAppWeb.Auth do
  import Plug.Conn

  def init(opts), do: opts

  # check if user is in the session
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && RewardApp.Accounts.get_user!(user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end
end
