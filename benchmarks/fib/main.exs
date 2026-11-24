defmodule Fib do
  def fib(n) do
    if n < 2, do: n, else: fib(n - 1) + fib(n - 2)
  end
  
  def main do
    n = 28
    result = fib(n)
    IO.puts(result)
  end
end

Fib.main()
