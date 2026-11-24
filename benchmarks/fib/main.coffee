fib = (n) ->
 return if n < 2 then n else (fib(n - 1) + fib(n - 2));

n = 28;
result = fib n
console.log result
