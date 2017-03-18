defmodule HandlerMessages do

  # Commands
  @command_ranking ~r/ranking/
  @command_top ~r/top\s*(\d*)\s*/
  @command_score ~r/score.*<@.*?>/
  @command_give_chicken ~r/<@.*?>.*:chicken:/

  @username_pattern ~r/<@.*?>/

  def handle_message(message) do
    cond do
      Regex.match?(@command_give_chicken, message) -> update_score_for_users(message)
      Regex.match?(@command_ranking, message) -> send_ranking_message()
      Regex.match?(@command_top, message) -> send_top_users(message)
      Regex.match?(@command_score, message) -> send_current_score_for_user(message)
      true -> send_not_understood_message()
    end
  end

  # Handle responses

  defp send_ranking_message do
    get_ranking() |> format_ranking
  end

  defp update_score_for_users(message) do
    users = message |> retrieve_users_from_message
    users |> Enum.each(fn(user) -> HenhouseServer.add(user) end)
    users |> fetch_score_by_users |> format_ranking
  end

  defp send_current_score_for_user(message) do
    message |> retrieve_users_from_message |> fetch_score_by_users |> format_ranking
  end

  defp send_top_users(message) do
    top = Regex.run(@command_top, message) |> Enum.at(1) |> parse_top_number
    get_ranking() |> Enum.take(top) |> format_ranking
  end

  defp send_not_understood_message do
    "Whaaaaaaaaat?!?"
  end

  # Utils

  defp get_ranking do
    HenhouseServer.read |> order_ranking
  end

  defp order_ranking(ranking) do
    ranking
    |> Enum.sort(&(elem(&1, 1) >= elem(&2, 1)))
  end

  defp retrieve_users_from_message(message) do
    message
    |> String.split(@username_pattern, include_captures: true)
    |> Enum.filter(fn(x) -> String.match?(x, @username_pattern) == true end)
    |> Enum.uniq
  end

  defp fetch_score_by_users(users) do
    users |> Enum.reduce([], fn(user, acc) -> acc++[{user, HenhouseServer.get(user)}] end)
  end

  defp format_ranking(ranking) when ranking == [] do
    "> Thanks God, Nobody has yet received a chicken"
  end
  defp format_ranking(ranking) do
    IO.puts inspect(ranking)
    ranking
    |> Enum.reduce("", fn(user, acc) -> acc <> format_user_in_rank(user) end)
  end

  defp format_user_in_rank(user) do
    value = elem(user, 1) |> get_value |> Integer.to_string
    "> #{elem(user, 0)} has received *#{value}* :chicken:\n"
  end

  defp get_value(value) when value == nil do 0 end
  defp get_value(value) do value end

  defp parse_top_number(top) when top == "" do 5 end
  defp parse_top_number(top) when top == "0" do 5 end
  defp parse_top_number(top) do top |> String.to_integer end
end
