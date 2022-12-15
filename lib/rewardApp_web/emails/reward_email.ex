defmodule RewardAppWeb.Emails.RewardEmail do
  use Phoenix.Swoosh, view: RewardAppWeb.EmailView

  def reward_email(user, reward) do
    IO.puts("++++")
    IO.inspect(user)
    IO.puts("++++")
    IO.inspect(reward)
    IO.puts("++++")
    new()
    |> to(user.email)
    |> from("Reward App")
    |> subject("You have received a reward!")
    |> render_body("reward_email.html", %{name: user.name, reward: reward.reward})
  end
end
