defmodule RewardApp.Email do
  use Bamboo.Template, view: RewardAppWeb.EmailView

  def reward_email(reward_id, user) do
    reward_name = RewardApp.Rewards.get_reward!(reward_id).name

    new_email()
    |> from("RewardApp@support")
    |> to(user.email)
    |> subject("You have redeemed a reward!")
    |> put_html_layout({RewardAppWeb.EmailLayoutView, "email.html"})
    |> render("reward_email.html", reward: reward_name, name: user.name)
  end
end
