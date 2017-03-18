defmodule TheChicken do
  use Application

  def start(_type, _args) do
    Slack.Bot.start_link(Bot, [], System.get_env("TOKEN_SLACK"))
    HenhouseServer.start_link
  end
end
