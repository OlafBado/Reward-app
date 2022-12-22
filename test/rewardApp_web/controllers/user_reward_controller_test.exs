defmodule RewardAppWeb.UserRewardControllerTest do
  use RewardAppWeb.ConnCase
  import Plug.Conn
  import RewardApp.RewardsFixtures
  import RewardApp.AccountsFixtures
  import RewardApp.UserRewardsFixtures

  @valid_attrs %{"report" => %{"month" => "12", "year" => "2022"}}

  describe "index" do
    setup [:create_admin_user, :create_user_reward]

    test "redirects to home page when not signed in", %{conn: conn} do
      conn = get(conn, Routes.user_reward_path(conn, :index))
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "lists all user_rewards when user is signed in", %{conn: conn, admin_user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.user_reward_path(conn, :index))
      assert html_response(conn, 200)
      assert length(conn.assigns.user_rewards) >= 1
    end
  end

  describe "create user reward" do
    setup [:create_reward, :create_admin_user]

    test "redirects to home page when not signed in", %{conn: conn} do
      conn = post(conn, Routes.user_reward_path(conn, :create))
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "shows error and redirects to rewards index page when user doesn't have enough points",
         %{
           conn: conn,
           admin_user: user,
           reward: reward
         } do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.user_reward_path(conn, :create), %{"reward_id" => reward.id})
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/rewards"
      assert get_flash(conn, :error) == "You don't have enough points to redeem this reward."
    end

    test "shows success and redirects to rewards index page when user has enough points",
         %{
           conn: conn,
           admin_user: user,
           reward: reward
         } do
      {_, user} = RewardApp.Accounts.update_user(user, %{"total_points" => "300"})
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.user_reward_path(conn, :create), %{"reward_id" => reward.id})
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/rewards"
      assert get_flash(conn, :info) == "The reward has been successfully selected."
    end
  end

  describe "new" do
    setup [:create_admin_user]

    test "redirects if user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.user_reward_path(conn, :new))
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "redirects if user is logged in but not an admin", %{conn: conn} do
      user = user_fixture(%{name: "abc", email: "exp@exp"})
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.user_reward_path(conn, :new))
      assert user.role != "admin"
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be an admin to access this page."
    end

    test "renders form for report if user is logged in and an admin", %{
      conn: conn,
      admin_user: admin_user
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = get(conn, Routes.user_reward_path(conn, :new))
      assert html_response(conn, 200)
    end
  end

  describe "show" do
    setup [:create_admin_user]

    test "redirects if user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.user_reward_path(conn, :show), @valid_attrs)

      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "redirects if user is logged in but not an admin", %{conn: conn} do
      user = user_fixture(%{name: "abc", email: "exp@exp"})
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.user_reward_path(conn, :show), @valid_attrs)
      assert user.role != "admin"
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be an admin to access this page."
    end

    test "renders report if user is logged in and an admin", %{
      conn: conn,
      admin_user: admin_user
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = get(conn, Routes.user_reward_path(conn, :show), @valid_attrs)
      assert html_response(conn, 200)
      assert length(conn.assigns.users) >= 1
    end
  end

  defp create_reward(_) do
    reward = reward_fixture()
    %{reward: reward}
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp create_admin_user(_) do
    user = user_fixture(%{name: "admin", email: "admin@admin", role: "admin"})
    %{admin_user: user}
  end

  defp create_user_reward(_) do
    user_reward = user_reward_fixture()
    %{user_reward: user_reward}
  end
end
