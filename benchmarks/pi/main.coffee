calculate_pi = (n_terms) ->
 terms = n_terms * 2.0 + 1.0
 pi = 0.0
 denominator = 1.0
 operation = 1.0

 while denominator < terms
  pi += operation * (4.0 / denominator)
  denominator += 2.0
  operation *= -1.0

 return pi

n = 1000000.0
result = calculate_pi(n)
console.log result

