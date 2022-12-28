defmodule RewardAppWeb.PageViewTest do
  use RewardAppWeb.ConnCase, async: true
  import Phoenix.View

  alias RewardAppWeb.PageView

  test "renders index.html", %{conn: conn} do
    content = render_to_string(PageView, "index.html", conn: conn)

    assert String.contains?(content, "Employee Reward App")
  end
end
