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

  def calculate_category_breakdown() do
    data = File.read!(@expenses_file)

    data
    |> String.split("~", trim: true)
    |> Enum.map(&(String.split(&1, "\n", trim: true)))
    |> List.flatten()
    |> parse_list_into_category_tuples()
    |> Enum.group_by(fn {_p, c} -> c end, fn {p, _c} -> p end)
    |> Enum.map(fn {c, prices_list} -> {c, Float.round(Enum.sum(prices_list), 2)} end)
    |> Enum.each(fn {category, price} ->
      category_display_name =
        category
        |> String.replace("@", "")
        |> String.capitalize()

        if String.length(category_display_name) < 6 do
          IO.puts("#{category_display_name}: \t\t$#{price}")
        else
          IO.puts("#{category_display_name}: \t$#{price}")
        end
      end)
  end

  def calculate_most_expensive_expenditures() do
    data = File.read!(@expenses_file)

    entries =
      data
      |> String.split("~", trim: true)
      |> Enum.map(&(String.split(&1, "\n", trim: true)))
      |> List.flatten()
      |> parse_list_into_description_tuples()
      |> Enum.group_by(fn {[first_el | _rest], _p} -> first_el end, fn {_l, p} -> p end)
      |> Enum.map(fn {description, prices_list} -> {description, Enum.sum(prices_list)} end)
      |> Enum.sort_by(fn {_d, p} -> p end, :desc)
      |> Enum.take(5)

    for {entry, total} <- entries do
      if String.length(entry) < 7 do
        IO.puts("#{String.capitalize(entry)}:\t\t $#{Float.round(total, 2)}")
      else
        IO.puts("#{String.capitalize(entry)}:\t $#{Float.round(total, 2)}")
      end
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

  defp parse_list_into_category_tuples(expenses_list) do
    expenses_list
    |> Enum.map(fn line ->
      {unformatted_price, category} =
        line
        |> String.split("-", trim: true)
        |> List.first()
        |> String.split(" ", trim: true)
        |> List.to_tuple()

        price = String.to_float(unformatted_price)

        {price, category}
    end)
  end

  defp parse_list_into_description_tuples(expenses_list) do
    expenses_list
    |> Enum.map(fn line ->
      description_list =
        line
        |> String.split("-", trim: true)
        |> List.last()
        |> String.split(" ", trim: true)
        |> Enum.drop(-1)
        |> List.flatten()

      price_list =
        line
        |> String.split("-", trim: true)
        |> List.first()
        |> String.split(" ", trim: true)
        |> List.first()
        |> String.to_float()

      {description_list, price_list}
    end)

  end
end

IO.puts("Total expenses for the month: $#{ExpenseCalculator.calculate_monthly_total()}\n")
IO.puts("* Week one:   $#{ExpenseCalculator.calculate_weekly_total(1)}")
IO.puts("* Week two:   $#{ExpenseCalculator.calculate_weekly_total(2)}")
IO.puts("* Week three: $#{ExpenseCalculator.calculate_weekly_total(3)}")
IO.puts("* Week four:  $#{ExpenseCalculator.calculate_weekly_total(4)}\n")
IO.puts("Daily average: $#{ExpenseCalculator.calculate_daily_average()}\n")
IO.puts("Top 5 most expensive entries:\n")
ExpenseCalculator.calculate_most_expensive_expenditures();
IO.puts("")
IO.puts("Category breakdown: \n")
ExpenseCalculator.calculate_category_breakdown()
