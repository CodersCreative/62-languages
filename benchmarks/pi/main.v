fn calculate_pi(n_terms f64) f64 {
	terms := n_terms * 2.0 + 1.0
	mut pi := 0.0
	mut denominator := 1.0
	mut operation := 1.0

	for denominator < terms {
		pi += operation * (4.0 / denominator)
		denominator += 2.0
		operation *= -1.0
	}

	return pi
}

fn main() {
	n := 1000000.0
	result := calculate_pi(n)
	println(result)
}
