fn fib(n int) int {
	return if n < 2 { n } else { (fib(n - 1) + fib(n - 2)) }
}

fn main() {
	n := 28
	result := fib(n)
	println(result)
}
