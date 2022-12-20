defmodule RewardAppWeb.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, opts) do
    IO.puts("++++++")
    IO.inspect(opts)
    IO.puts("++++++")

    if conn.assigns.current_user.role == "admin" do
      conn
    else
      conn
      |> put_flash(:error, "You must be an admin to access this page.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
