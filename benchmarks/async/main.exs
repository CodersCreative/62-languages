defmodule Async do
  def worker(id) do
    sum = Enum.reduce(0..500000, 0, fn i, sum ->
      sum + i * i
    end)

    IO.puts("task #{id} = #{sum}")
  end

  def main do
    tasks = Enum.map(0..64, fn i ->
      Task.async(fn -> worker(i) end)
    end)

    Task.await_many(tasks)

    IO.puts("all tasks finished")
  end
end

Async.main()
