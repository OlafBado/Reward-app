defmodule RewardAppWeb.Auth do
  import Plug.Conn
  alias RewardApp.Repo
  def init(opts), do: opts
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(RewardApp.Accounts.User, user_id) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
