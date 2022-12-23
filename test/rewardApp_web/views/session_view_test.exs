defmodule RewardAppWeb.SessionViewTest do
  use RewardAppWeb.ConnCase, async: true
  import Phoenix.View
  alias RewardAppWeb.SessionView

  test "renders new.html", %{conn: conn} do
    content = render_to_string(SessionView, "new.html", conn: conn)

    assert String.contains?(content, "Log in")
  end
end
