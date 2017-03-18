defmodule Bot do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    Regex.run(~r/<@#{slack.me.id}>\s*(.*)/, message.text)
    |> handle_message(message.channel, slack)
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, _slack, state) do
    IO.puts "Info: #{inspect({:message, text, channel})}"
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}

  defp handle_message(message, channel, slack) when message != nil do
    message
    |> Enum.at(1)
    |> HandlerMessages.handle_message
    |> send_message(channel, slack)
  end
  defp handle_message(_message, _, _) do end
end
