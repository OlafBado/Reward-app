defmodule RewardAppWeb.SessionController do
  use RewardAppWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case RewardApp.Accounts.authenticate_by_email_and_password(email, password) do
      {:ok, user} ->
        conn
        |> RewardAppWeb.Auth.login(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password.")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> RewardAppWeb.Auth.logout()
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
