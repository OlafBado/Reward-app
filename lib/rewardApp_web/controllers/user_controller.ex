defmodule RewardAppWeb.UserController do
  use RewardAppWeb, :controller

  alias RewardApp.Accounts
  alias RewardApp.Accounts.User

  plug RewardAppWeb.RequireAuth when action in [:index, :show, :edit, :update, :delete, :send]
  plug :check_profile_owner when action in [:edit, :update, :delete]

  defp check_profile_owner(conn, _params) do
    %{:path_params => %{"id" => id}} = conn

    if conn.assigns.current_user.id == String.to_integer(id) || conn.assigns.current_user.role == "admin"  do
      conn
    else
      conn
      |> put_flash(:error, "You must be the owner of this profile to access this page.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_registration(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> RewardAppWeb.Auth.login(user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was an error creating the user.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was an error updating the user.")
        |> render("edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
  def send(conn, %{"id" => receiver_id, "user" => %{"points" => points}}) do
    case Accounts.validate_points(points) do
      {:ok, points} ->
        case Accounts.send_points(conn.assigns.current_user, receiver_id, points) do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "Points sent successfully.")
            |> redirect(to: Routes.user_path(conn, :index))

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "You do not have enough points to send.")
            |> redirect(to: Routes.user_path(conn, :index))
        end
      {:error, :zero_points} ->
        conn
        |> put_flash(:error, "You must send at least 1 point.")
        |> redirect(to: Routes.user_path(conn, :index))
      {:error, :negative_points} ->
        conn
        |> put_flash(:error, "You cannot send negative points.")
        |> redirect(to: Routes.user_path(conn, :index))
      {:error, :empty_points} ->
        conn
        |> put_flash(:error, "You must enter a number of points to send.")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

end
