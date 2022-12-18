defmodule RewardApp.Email do
  use Bamboo.Template, view: RewardAppWeb.EmailView

  def reward_email(user_reward, user) do
    new_email()
    |> from("RewardApp Support")
    |> to(user.email)
    |> subject("You have redeemed a reward!")
    |> put_html_layout({RewardAppWeb.EmailLayoutView, "email.html"})
    |> render("reward_email.html", reward: user_reward.reward, name: user.name)
  end
end
