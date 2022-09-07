defmodule ExpenseCalculator do
  @expenses_file "expenses.txt"

  def calculate_monthly_total() do
    data = File.read!(@expenses_file)

    sum =
      data
      |> String.split("\n", trim: true)
      |> Enum.map_reduce(0, fn line, acc ->
        cv =
          line
          |> String.split(" ")
          |> List.first()
          |> check_if_float()

        {cv, cv + acc}
      end)

    {_expense_values_list, total} = sum

    :erlang.float_to_binary(total, [decimals: 2])
  end

  def calculate_weekly_total(week_number) do
    data = File.read!(@expenses_file)

    sum =
      data
      |> String.split("~", trim: true)
      |> Enum.at(week_number - 1)
      |> check_for_input()
      |> String.split("\n", trim: true)
      |> Enum.map_reduce(0, fn line, acc ->
        cv =
          line
          |> String.split(" ")
          |> List.first()
          |> String.to_float()

        {cv, cv + acc}
      end)

    {_expense_values_list, total} = sum

    cond do
      is_float(total) -> :erlang.float_to_binary(total, [decimals: 2])
      true -> 0.0
    end
  end

  defp check_if_float(input) do
    try do
      String.to_float(input)
    rescue
      _e -> 0
    end
  end

  defp check_for_input(nil), do: ""
  defp check_for_input(data), do: data
end

IO.puts("Total expenses for the month: #{ExpenseCalculator.calculate_monthly_total()}\n")
IO.puts("* Week one: #{ExpenseCalculator.calculate_weekly_total(1)}")
IO.puts("* Week two: #{ExpenseCalculator.calculate_weekly_total(2)}")
IO.puts("* Week three: #{ExpenseCalculator.calculate_weekly_total(3)}")
IO.puts("* Week four: #{ExpenseCalculator.calculate_weekly_total(4)}")
