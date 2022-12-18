defmodule RewardApp.Email do
  import Bamboo.Email

  def welcome_email do
    new_email(
      to: "niebiel1@gmail.com",
      from: "support@myapp.com",
      subject: "hello:D production",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )
  end
end
