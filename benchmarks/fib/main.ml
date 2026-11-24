let rec fib (n : int) : int =
    if n < 2 then n else fib(n - 1) + fib(n - 2)

let () =
	let n = 28 in
	let result = fib n in
	print_int(result);
	print_newline()

