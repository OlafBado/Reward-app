defmodule RewardAppWeb.RewardControllerTest do
  use RewardAppWeb.ConnCase, async: true

  alias RewardApp.Rewards

  @valid_attrs %{name: "some name", description: "some description", price: 100}

  test "requires user authentication on given actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.reward_path(conn, :index)),
        get(conn, Routes.reward_path(conn, :new)),
        post(conn, Routes.reward_path(conn, :create), %{}),
        get(conn, Routes.reward_path(conn, :edit, 1)),
        put(conn, Routes.reward_path(conn, :update, 1), %{})
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert redirected_to(conn) == Routes.session_path(conn, :new)
        assert conn.halted
      end
    )
  end

  describe "with a logged in user" do
    setup [:create_reward, :login]

    @tag login_as: %{name: "juri"}
    test "requires admin role on given actions even if logged in", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.reward_path(conn, :new)),
          post(conn, Routes.reward_path(conn, :create), %{}),
          get(conn, Routes.reward_path(conn, :edit, 1)),
          put(conn, Routes.reward_path(conn, :update, 1), %{})
        ],
        fn conn ->
          assert html_response(conn, 302)
          assert redirected_to(conn) == Routes.page_path(conn, :index)
          assert get_flash(conn, :error) == "You must be an admin to access this page."
        end
      )
    end

    @tag login_as: %{name: "juri"}
    test "lists all rewards", %{conn: conn} do
      conn = get(conn, Routes.reward_path(conn, :index))

      assert html_response(conn, 200)
      assert rewards_count() == 1
    end

    @tag login_as: %{name: "juri", role: "admin"}
    test "shows form", %{conn: conn} do
      conn = get(conn, Routes.reward_path(conn, :new))

      assert html_response(conn, 200)
    end

    @tag login_as: %{name: "juri", role: "admin"}
    test "redirects to index when data is valid and creates reward",
         %{conn: conn} do
      assert rewards_count() == 1
      conn = post(conn, Routes.reward_path(conn, :create), reward: @valid_attrs)
      assert rewards_count() == 2
      assert redirected_to(conn) == Routes.reward_path(conn, :index)
      assert get_flash(conn, :info) == "Reward created successfully."
    end
  end

  describe "create reward" do
    setup [:create_user, :create_admin_user]

    test "renders errors when given name of is blank", %{conn: conn, admin_user: admin_user} do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)

      conn =
        post(conn, Routes.reward_path(conn, :create), reward: Map.put(@valid_attrs, :name, ""))

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."
      assert conn.assigns.changeset.errors[:name] == {"can't be blank", [validation: :required]}
    end

    test "renders errors when given description is blank", %{
      conn: conn,
      admin_user: admin_user
    } do
      conn = Plug.Test.init_test_session(conn, user_id: admin_user.id)

      conn =
        post(conn, Routes.reward_path(conn, :create),
          reward: Map.put(@valid_attrs, :description, "")
        )

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

      conn =
        post(conn, Routes.reward_path(conn, :create), reward: Map.put(@valid_attrs, :price, -1))

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

    test "redirects to home page when signed in but not an admin", %{
      conn: conn,
      user: user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.reward_path(conn, :edit, reward))

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
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

    test "redirects to home page when signed in but not an admin", %{
      conn: conn,
      user: user,
      reward: reward
    } do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = put(conn, Routes.reward_path(conn, :update, reward), %{"reward" => @valid_attrs})

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
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

      conn =
        put(conn, Routes.reward_path(conn, :update, reward),
          reward: Map.put(@valid_attrs, :name, "")
        )

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
        put(conn, Routes.reward_path(conn, :update, reward),
          reward: Map.put(@valid_attrs, :description, "")
        )

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

      conn =
        put(conn, Routes.reward_path(conn, :update, reward),
          reward: Map.put(@valid_attrs, :price, -1)
        )

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

  defp rewards_count, do: Enum.count(Rewards.list_rewards())

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
