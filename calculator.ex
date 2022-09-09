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

    Float.round(total, 2)
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
      is_float(total) -> Float.round(total, 2)
      true -> 0.0
    end
  end

  def calculate_daily_average() do
    data = File.read!(@expenses_file)

    first_day =
      data
      |> String.split("\n")
      |> List.first()
      |> String.split(" ", trim: true)
      |> List.last()

    first_day_iso =
      Date.new!(
        2022,
        get_date(first_day, :month),
        get_date(first_day, :day)
      )

    last_day =
      data
      |> String.split("\n", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)
      |> List.last()

    last_day_iso =
      Date.new!(
        2022,
        get_date(last_day, :month),
        get_date(last_day, :day)
      )

      Float.round(calculate_monthly_total() / Date.diff(last_day_iso, first_day_iso), 2)
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

  defp get_date(date_string, :month) do
    date_string
    |> String.split("/")
    |> List.first()
    |> String.to_integer()
  end
  defp get_date(date_string, :day) do
    date_string
    |> String.split("/")
    |> List.last()
    |> String.to_integer()
  end
end

IO.puts("Total expenses for the month: $#{ExpenseCalculator.calculate_monthly_total()}\n")
IO.puts("Daily average: $#{ExpenseCalculator.calculate_daily_average()}\n")
IO.puts("* Week one:   $#{ExpenseCalculator.calculate_weekly_total(1)}")
IO.puts("* Week two:   $#{ExpenseCalculator.calculate_weekly_total(2)}")
IO.puts("* Week three: $#{ExpenseCalculator.calculate_weekly_total(3)}")
IO.puts("* Week four:  $#{ExpenseCalculator.calculate_weekly_total(4)}")
