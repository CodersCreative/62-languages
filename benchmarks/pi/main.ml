let calculate_pi (n_terms : float) : float = 
	let terms = n_terms *. 2.0 +. 1.0 in
	let pi = ref 0.0 in
	let denominator = ref 1.0 in
	let operation = ref 1.0 in
	while !denominator < terms do
		pi := !pi +. !operation *. (4.0 /. !denominator);
		denominator := !denominator +. 2.0;
		operation := !operation *. -1.0;
	done;
	!pi

let () =
	let n = 1000000.0 in
	let result = calculate_pi n in
	print_float(result);
  prerr_newline()
