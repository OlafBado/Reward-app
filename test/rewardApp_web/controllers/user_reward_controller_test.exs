defmodule RewardAppWeb.UserRewardControllerTest do
  use RewardAppWeb.ConnCase, async: true

  @valid_attrs %{"report" => %{"month" => "12", "year" => "2022"}}

  test "requires user authentication on given actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.user_reward_path(conn, :index)),
        post(conn, Routes.user_reward_path(conn, :create), %{}),
        get(conn, Routes.user_reward_path(conn, :show), %{}),
        get(conn, Routes.user_reward_path(conn, :new))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == Routes.session_path(conn, :new)
        assert conn.halted
      end
    )
  end

  describe "index/2" do
    setup [:login, :create_user_reward]

    @tag login_as: %{name: "juri", email: "123@321", role: "member"}
    test "requires admin role even if logged in", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.user_reward_path(conn, :show), %{}),
          get(conn, Routes.user_reward_path(conn, :new))
        ],
        fn conn ->
          assert html_response(conn, 302)
          assert redirected_to(conn) == Routes.page_path(conn, :index)
          assert get_flash(conn, :error) == "You must be an admin to access this page."
        end
      )
    end

    @tag login_as: %{name: "juri", email: "123@321", role: "member"}
    test "lists all user_rewards", %{conn: conn} do
      conn = get(conn, Routes.user_reward_path(conn, :index))
      assert html_response(conn, 200)
      assert length(conn.assigns.user_rewards) == 1
    end
  end

  describe "create user reward" do
    setup [:login, :create_reward]

    @tag login_as: %{name: "juri", email: "123@321", role: "admin"}, attrs: %{price: 200}
    test "shows error and redirects to rewards index page when user doesn't have enough points",
         %{
           conn: conn,
           reward: reward
         } do
      conn = post(conn, Routes.user_reward_path(conn, :create), %{"reward_id" => reward.id})
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.reward_path(conn, :index)
      assert get_flash(conn, :error) == "You don't have enough points to redeem this reward."
    end

    @tag login_as: %{name: "juri", email: "123@321", role: "admin"}, attrs: %{price: 20}
    test "shows success and redirects to rewards index page when user has enough points",
         %{
           conn: conn,
           reward: reward
         } do
      conn = post(conn, Routes.user_reward_path(conn, :create), %{"reward_id" => reward.id})
      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.reward_path(conn, :index)
      assert get_flash(conn, :info) == "The reward has been successfully selected."
    end
  end

  describe "new" do
    setup [:login]

    @tag login_as: %{name: "juri", email: "123@321", role: "admin"}, attrs: %{price: 20}
    test "renders form for report", %{
      conn: conn
    } do
      conn = get(conn, Routes.user_reward_path(conn, :new))
      assert html_response(conn, 200)
    end
  end

  describe "show" do
    setup [:login]

    @tag login_as: %{name: "juri", email: "123@321", role: "admin"}, attrs: %{price: 20}
    test "renders report", %{
      conn: conn
    } do
      conn = get(conn, Routes.user_reward_path(conn, :show), @valid_attrs)
      assert html_response(conn, 200)
      assert length(conn.assigns.users) >= 1
    end
  end

  describe "send email to user after choosing reward" do
    setup [:create_reward, :login]

    @tag login_as: %{name: "juri", email: "123@321", role: "admin"}, attrs: %{price: 20}
    test "send_reward_email", %{user: user, reward: reward} do
      email = RewardAppWeb.UserRewardController.send_reward_email(reward.id, user)
      assert {_, %{assigns: %{name: name, reward: received_reward}}} = email
      assert name == user.name
      assert received_reward == reward.name
    end
  end
end
