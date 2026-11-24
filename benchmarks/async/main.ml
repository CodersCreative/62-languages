let worker (id : int) =
	let rec loop (i : int) (sum : int) =
	  if i > 0 then
	    loop(i - 1)(sum + i * i)
  	else
  	  sum
	in
	let sum = loop(500000)(0) in
	Printf.printf "task %d = %d\n" id sum

let () =
  let tasks = List.init(64)(fun i -> Domain.spawn(fun () -> worker i)) in
  List.iter(Domain.join)(tasks);
	print_endline("all tasks finished")
