defmodule PI do
  def calculate_pi(n_terms) do
    terms = n_terms * 2.0 + 1.0
    calculate_pi_loop(terms, 0.0, 1.0, 1.0)
  end

  def calculate_pi_loop(terms, pi, denominator, operation) do
    if denominator < terms do
      pi = pi + operation * (4.0 / denominator)
  		denominator = denominator + 2.0;
  		operation = operation * -1.0;
  		calculate_pi_loop(terms, pi, denominator, operation)
    else
      pi
    end
  end

  def main do
    n = 1000000.0
    result = calculate_pi n
    IO.puts result
  end
end

PI.main()
