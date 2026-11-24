type arg_state =
  | Delete
  | Squeeze

type 'a set = {
  value : 'a;
  complement : bool;
}

type operation =
  | Range of char * char
  | Letter of char

let string_to_list (value : string) : char list = 
  List.of_seq(String.to_seq(value))

let list_to_string (value : char list) : string = 
  String.of_seq(List.to_seq(value))

let remove_char (value : string) (target : char) : string =
  value
  |> string_to_list
  |> List.filter(fun ch -> ch != target)
  |> list_to_string

let range_to_list(start: char)(last : char) : char list =
  let start, last =
    let start, last = Char.code start, Char.code last in
    if start > last then (last, start) else (start, last)
  in
  List.init(last - start + 1)(fun i -> Char.chr(start + i))


let convert_str_to_operations (value : string) : operation list =
  let rec loop characters in_range left values =
    match characters, left with
    | [], Some v -> List.rev (Letter v :: values)
    | [], None -> List.rev values
    | ch :: rest, Some v when ch == '-' ->
      loop rest true (Some v) values
    | ch :: rest, Some v when in_range ->
      loop rest false None (Range(v, ch) :: values)
    | ch :: rest, Some v ->
      loop rest false None (Letter(v) :: values)
    | ch :: rest, None ->
      loop rest false (Some ch) values
  in
  loop (string_to_list value) false None []

let evaluate (text : string) (ops : operation list set) (state : arg_state) : string =
  let text = ref text in
  let characters = ref [] in

  List.iter(fun op ->
    match state, op with
    | Delete, Letter v when not ops.complement ->
      text := remove_char !text v
    | Delete, Range (start, last) when not ops.complement ->
      List.iter(fun ch ->
        text := remove_char !text ch)(range_to_list start last)
    | _, Letter v -> characters := !characters @ [ v ]
    | _, Range (start, last) -> characters := !characters @ range_to_list(start)(last)
    )(ops.value);

  if not(List.is_empty(!characters)) then
    let out = Buffer.create(String.length !text) in
    begin match state with
    | Delete ->
      List.iter(fun ch ->
        if List.mem(ch)(!characters) then Buffer.add_char(out)(ch))
        (string_to_list !text)
    | Squeeze ->
      let current = ref None in
      List.iter(fun ch ->
        let within = List.mem(ch)(!characters) in
        let within = if ops.complement then not within else within in
        if within then
          match !current with
          | Some c when c != ch -> Buffer.add_char(out)(c)
          | _ -> ();
          current := Some ch
        else
          match !current with
          | Some c ->
            Buffer.add_char(out)(c);
            current := None
          | _ -> ();
          Buffer.add_char(out)(ch)
        )(string_to_list !text);
      match !current with
      | Some c -> Buffer.add_char(out)(c)
      | _ -> ()
    end;

    Buffer.contents out
  else
    !text

let main () =
  let args = if Array.length(Sys.argv) > 1 then
    Array.to_list(Array.sub(Sys.argv)(1)(Array.length(Sys.argv) - 1))
  else
    []
  in
  let values = ref [] in
  let deleting = ref [] in
  let squeezing = ref [] in
  let complement = ref false in
  let state = ref (None : arg_state option) in
  List.iter(fun arg ->
    if String.length(arg) > 0 && arg.[0] == '-' then
      String.iter(fun ch ->
        match ch with
        | '-' -> ()
        | 'c' -> complement := true
        | 'd' -> state := Some Delete
        | 's' -> state := Some Squeeze
        | _ ->
          print_endline("Invalid argument entered")
        )(arg)
    else begin
      match !state with
      | Some Delete ->
        deleting := !deleting @ [ {value = arg; complement = !complement} ];
        state := None;
        complement := false
      | Some Squeeze ->
        squeezing := !squeezing @ [ {value = arg; complement = !complement} ];
        state := None;
        complement := false
      | None ->
        values := !values @ [ arg ];
        complement := false
    end
    )(args);
    
  match !values with
  | [] -> prerr_endline("Please enter an input string")
  | value :: _ ->
    let deleting = List.map(fun x -> {value = convert_str_to_operations(x.value); complement = x.complement})(!deleting) in
    let squeezing = List.map(fun x -> {value = convert_str_to_operations(x.value); complement = x.complement})(!squeezing) in
    let value = List.fold_left(fun value op -> evaluate value op Delete)(value)(deleting) in
    let value = List.fold_left(fun value op -> evaluate(value)(op)(Squeeze))(value)(squeezing) in
    print_endline(value)

let () = main()
