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

    @tag login_as: %{name: "juri"}, attrs: %{}
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

    @tag login_as: %{name: "juri"}, attrs: %{}
    test "lists all rewards", %{conn: conn} do
      conn = get(conn, Routes.reward_path(conn, :index))

      assert html_response(conn, 200)
      assert rewards_count() == 1
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "shows form", %{conn: conn} do
      conn = get(conn, Routes.reward_path(conn, :new))

      assert html_response(conn, 200)
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "redirects to index when data is valid and creates reward",
         %{conn: conn} do
      assert rewards_count() == 1
      conn = post(conn, Routes.reward_path(conn, :create), reward: @valid_attrs)
      assert rewards_count() == 2
      assert redirected_to(conn) == Routes.reward_path(conn, :index)
      assert get_flash(conn, :info) == "Reward created successfully."
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "renders errors when given is blank", %{conn: conn} do
      %{assigns: %{changeset: changeset}} =
        conn =
        post(conn, Routes.reward_path(conn, :create), reward: Map.put(@valid_attrs, :name, ""))

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "renders errors when given description is blank", %{
      conn: conn
    } do
      %{assigns: %{changeset: changeset}} =
        conn =
        post(conn, Routes.reward_path(conn, :create),
          reward: Map.put(@valid_attrs, :description, "")
        )

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."

      assert %{description: ["can't be blank"]} == errors_on(changeset)
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "renders error when given price is negative", %{
      conn: conn
    } do
      %{assigns: %{changeset: changeset}} =
        conn =
        post(conn, Routes.reward_path(conn, :create), reward: Map.put(@valid_attrs, :price, -1))

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."

      assert %{price: ["Price can't be negative"]} == errors_on(changeset)
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "shows edit reward form", %{
      conn: conn,
      reward: reward
    } do
      conn = get(conn, Routes.reward_path(conn, :edit, reward))
      assert html_response(conn, 200)
      assert String.contains?(conn.resp_body, "Edit #{reward.name}")
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "updates reward and redirects to index when data is valid", %{
      conn: conn,
      reward: reward
    } do
      assert reward.name == "ticket"
      conn = put(conn, Routes.reward_path(conn, :update, reward), %{"reward" => @valid_attrs})

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.reward_path(conn, :index)
      assert get_flash(conn, :info) == "Reward updated successfully."
      updated_reward = Rewards.get_reward!(reward.id)
      assert updated_reward.id == reward.id
      assert updated_reward.name == "some name"
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "update: renders errors when given name is blank", %{
      conn: conn,
      reward: reward
    } do
      %{assigns: %{changeset: changeset}} =
        conn =
        put(conn, Routes.reward_path(conn, :update, reward),
          reward: Map.put(@valid_attrs, :name, "")
        )

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "update: renders errors when given description is blank", %{
      conn: conn,
      reward: reward
    } do
      %{assigns: %{changeset: changeset}} =
        conn =
        put(conn, Routes.reward_path(conn, :update, reward),
          reward: Map.put(@valid_attrs, :description, "")
        )

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."

      assert %{description: ["can't be blank"]} == errors_on(changeset)
    end

    @tag login_as: %{name: "juri", role: "admin"}, attrs: %{}
    test "renders errors when given price is negative", %{
      conn: conn,
      reward: reward
    } do
      %{assigns: %{changeset: changeset}} =
        conn =
        put(conn, Routes.reward_path(conn, :update, reward),
          reward: Map.put(@valid_attrs, :price, -1)
        )

      assert html_response(conn, 200)
      assert get_flash(conn, :error) == "Something went wrong."

      assert %{price: ["Price can't be negative"]} == errors_on(changeset)
    end
  end

  defp rewards_count, do: Enum.count(Rewards.list_rewards())
end
