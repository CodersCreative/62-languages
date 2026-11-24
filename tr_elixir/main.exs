defmodule Operation do
  defstruct [:value, :complement]
end

defmodule StartingState do
  defstruct [:values, :deleting, :squeezing, :complement, :state, :error]
end

defmodule TR do
  @type arg_state :: :delete | :squeeze
  @type operation :: {:range, char, char} | {:letter, char}

  def convert_str_to_operations(value) do
    {ops, _, left} = Enum.reduce(String.to_charlist(value), {[], false, nil}, fn
      ?-, {ops, false, left} when not is_nil(left) ->
        {ops, true, left}
      ch, {ops, true, left} ->
        {ops ++ [{:range, left, ch}], false, nil}
      ch, {ops, false, left} when not is_nil(left) ->
        {ops ++ [{:letter, left}], false, ch}
      ch, {ops, false, nil} ->
        {ops, false, ch}
    end)

    ops = if not is_nil(left), do: ops ++ [{:letter, left}], else: ops
    ops
  end

  def remove_char(text, target) do
    List.to_string(
      Enum.filter(String.to_charlist(text), fn value -> value != target end)
    )
  end

  def range_to_list(start, last) do
    {start, last} = if start > last, do: {last, start}, else: {start, last}
    Enum.to_list(start..last)
  end

  def evaluate(text, ops, state) do
    {text, characters} = Enum.reduce(ops.value, {text, []}, fn op, {text, characters} ->
      case {state, op} do
        {:delete, {:letter, ch}} when not ops.complement ->
          {remove_char(text, ch), characters}

        {:delete, {:range, start, last}} when not ops.complement ->
          {
            Enum.reduce(range_to_list(start, last), text, fn ch, text ->
              remove_char(text, ch) 
            end),
            characters
          }

        {_, {:letter, ch}} ->
          {text, characters ++ [ch]}
        
        {_, {:range, start, last}} ->
          {text, characters ++ range_to_list(start, last)}       
      end
    end)

    if characters != [] do
      characters = MapSet.new(characters)

      out = case state do
        :delete ->
          Enum.filter(String.to_charlist(text), &MapSet.member?(characters, &1))

        :squeeze ->
          {out, current} = Enum.reduce(String.to_charlist(text), {[], nil}, fn ch, {out, current} ->
            within = MapSet.member?(characters, ch)
            within = if ops.complement, do: not within, else: within

            if within do
              out = if not is_nil(current) and current != ch, do: out ++ [current], else: out
              {
                out,
                ch
              }
            else
              out = if not is_nil(current), do: out ++ [current], else: out
              {
                out ++ [ch],
                nil
              }
            end
          end)

          if not is_nil(current), do: out ++ [current], else: out
      end

      List.to_string(out)
    else
      text
    end
  end
  
  def main do
    args = System.argv()
    initial = %StartingState{
      values: [],
      deleting: [],
      squeezing: [],
      complement: false,
      state: nil,
      error: nil
    }

    parsed =
      Enum.reduce_while(args, initial, fn
        "-" <> _ = arg, acc ->
          result =
            Enum.reduce_while(String.to_charlist(arg), acc, fn
              ?-, %StartingState{} = x -> {:cont, x}
              ?c, %StartingState{} = x -> {:cont, %StartingState{x | complement: true}}
              ?d, %StartingState{} = x -> {:cont, %StartingState{x | state: :delete}}
              ?s, %StartingState{} = x -> {:cont, %StartingState{x | state: :squeeze}}
              ch, %StartingState{} = x -> {:halt, %StartingState{x | error: "Invalid argument entered #{ch}"}}
            end)

          if not is_nil(result.error), do: {:halt, result}, else: {:cont, result}
        arg, %StartingState {state: :delete, complement: complement} = acc ->
          value = %Operation{value: arg, complement: complement}
          {:cont, %{acc | deleting: acc.deleting ++ [value], state: nil, complement: false}}
        arg, %StartingState {state: :squeeze, complement: complement} = acc ->
          value = %Operation{value: arg, complement: complement}
          {:cont, %{acc | squeezing: acc.squeezing ++ [value], state: nil, complement: false}}
        arg, _ = acc ->
          {:cont, %{acc | values: acc.values ++ [arg], complement: false}}
       end)

    if not is_nil(parsed.error) do
      IO.write(:standard_error, parsed.error)
    else
      case parsed.values do
        [] ->
          IO.write(:standard_error, "Please enter an input string")
        [value | _] ->
          deleting = Enum.map(parsed.deleting, fn
            %Operation{value: value, complement: complement} -> %Operation{value: convert_str_to_operations(value), complement: complement}
          end)

          squeezing = Enum.map(parsed.squeezing, fn
            %Operation{value: value, complement: complement} -> %Operation{value: convert_str_to_operations(value), complement: complement}
          end)

          value = Enum.reduce(deleting, value, fn x, value ->
            evaluate(value, x, :delete)
          end)

          value = Enum.reduce(squeezing, value, fn x, value ->
            evaluate(value, x, :squeeze)
          end)

          IO.puts value       
      end
    end
  end
end

TR.main()
