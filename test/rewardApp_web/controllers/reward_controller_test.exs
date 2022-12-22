defmodule RewardAppWeb.RewardControllerTest do
  use RewardAppWeb.ConnCase
  import Plug.Conn
  import RewardApp.RewardsFixtures
  import RewardApp.AccountsFixtures

  @valid_attrs %{name: "some name", description: "some description", price: 100}
  @invalid_attrs_name %{name: "", description: "some description", price: 100}
  @invalid_attrs_description %{name: "some name", description: "", price: 100}
  @invalid_attrs_price %{name: "some name", description: "some description", price: -2}

  describe "index" do
    setup [:create_reward, :create_user]

    test "redirects to home page when not signed in", %{conn: conn} do
      conn = get(conn, Routes.reward_path(conn, :index))

      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
    end

    test "lists all rewards when user is signed in", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.reward_path(conn, :index))

      assert html_response(conn, 200)
      assert length(conn.assigns.rewards) >= 1
    end
  end

  describe "new reward" do
    setup [:create_user, :create_admin_user]

    test "redirects to home page when not signed in", %{conn: conn} do
      conn = get(conn, Routes.reward_path(conn, :new))

      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
    end

    test "redirects to home page when signed in but not an admin", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.reward_path(conn, :new))

      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be an admin to access this page."
    end

    test "shows new reward form when signed in and an admin", %{
      conn: conn,
      admin_user: admin_user
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = get(conn, Routes.reward_path(conn, :new))

      assert html_response(conn, 200)
    end
  end

  describe "create reward" do
    setup [:create_user, :create_admin_user]

    test "redirects to home page when not signed in", %{conn: conn} do
      conn = post(conn, Routes.reward_path(conn, :create), %{"reward" => @valid_attrs})
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "redirects to home page when signed in but not an admin", %{
      conn: conn,
      user: user
    } do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.reward_path(conn, :create), %{"reward" => @valid_attrs})

      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be an admin to access this page."
    end

    test "when user signed in and admin redirects to index when data is valid and creates reward",
         %{conn: conn, admin_user: admin_user} do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = post(conn, Routes.reward_path(conn, :create), reward: @valid_attrs)

      assert redirected_to(conn) == Routes.reward_path(conn, :index)
      assert get_flash(conn, :info) == "Reward created successfully."
    end

    test "renders errors when given name of is blank", %{conn: conn, admin_user: admin_user} do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = post(conn, Routes.reward_path(conn, :create), reward: @invalid_attrs_name)
      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."
      assert conn.assigns.changeset.errors[:name] == {"can't be blank", [validation: :required]}
    end

    test "renders errors when given description is blank", %{
      conn: conn,
      admin_user: admin_user
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = post(conn, Routes.reward_path(conn, :create), reward: @invalid_attrs_description)
      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."

      assert conn.assigns.changeset.errors[:description] ==
               {"can't be blank", [validation: :required]}
    end

    test "renders errors when given price is negative", %{
      conn: conn,
      admin_user: admin_user
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = post(conn, Routes.reward_path(conn, :create), reward: @invalid_attrs_price)
      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."

      assert conn.assigns.changeset.errors[:price] ==
               {"Price can't be negative",
                [
                  validation: :number,
                  kind: :greater_than_or_equal_to,
                  number: 0
                ]}
    end
  end

  describe "edit reward" do
    setup [:create_user, :create_admin_user, :create_reward]

    test "redirects to home page when not signed in", %{conn: conn, reward: reward} do
      conn = get(conn, Routes.reward_path(conn, :edit, reward))
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "redirects to home page when signed in but not an admin", %{
      conn: conn,
      user: user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.reward_path(conn, :edit, reward))

      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be an admin to access this page."
    end

    test "shows edit reward form when signed in and an admin", %{
      conn: conn,
      admin_user: admin_user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = get(conn, Routes.reward_path(conn, :edit, reward))
      assert html_response(conn, 200)
    end
  end

  describe "update reward" do
    setup [:create_user, :create_reward, :create_admin_user]

    test "redirects to home page when not signed in", %{conn: conn, reward: reward} do
      conn = put(conn, Routes.reward_path(conn, :update, reward), %{"reward" => @valid_attrs})
      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be logged in to access this page."
    end

    test "redirects to home page when signed in but not an admin", %{
      conn: conn,
      user: user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = put(conn, Routes.reward_path(conn, :update, reward), %{"reward" => @valid_attrs})

      assert html_response(conn, 302)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "You must be an admin to access this page."
    end

    test "redirects to index when signed in and an admin and data is valid", %{
      conn: conn,
      admin_user: admin_user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = put(conn, Routes.reward_path(conn, :update, reward), %{"reward" => @valid_attrs})

      assert redirected_to(conn) == Routes.reward_path(conn, :index)
      assert get_flash(conn, :info) == "Reward updated successfully."
    end

    test "renders errors when given name is blank", %{
      conn: conn,
      admin_user: admin_user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = put(conn, Routes.reward_path(conn, :update, reward), reward: @invalid_attrs_name)
      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."
      assert conn.assigns.changeset.errors[:name] == {"can't be blank", [validation: :required]}
    end

    test "renders errors when given description is blank", %{
      conn: conn,
      admin_user: admin_user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)

      conn =
        put(conn, Routes.reward_path(conn, :update, reward), reward: @invalid_attrs_description)

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."

      assert conn.assigns.changeset.errors[:description] ==
               {"can't be blank", [validation: :required]}
    end

    test "renders errors when given price is negative", %{
      conn: conn,
      admin_user: admin_user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)
      conn = put(conn, Routes.reward_path(conn, :update, reward), reward: @invalid_attrs_price)
      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."

      assert conn.assigns.changeset.errors[:price] ==
               {"Price can't be negative",
                [
                  validation: :number,
                  kind: :greater_than_or_equal_to,
                  number: 0
                ]}
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
end
