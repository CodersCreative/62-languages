module main

struct Set[T] {
	value      T
	complement bool
}

enum ArgState {
	delete
	squeeze
}

struct Range {
	start rune
	end   rune
}

type Operation = rune | Range

fn convert_str_to_operations(value string) []Operation {
	mut operations := []Operation{}
	mut in_range := false
	mut left := ?rune(none)

	for ch in value.runes() {
		if v := left {
			if ch == `-` {
				in_range = true
			} else if in_range {
				operations << Operation(Range{
					start: v
					end:   ch
				})

				in_range = false
				left = none
			} else {
				operations << Operation(v)
				left = ch
			}
		} else {
			left = ch
		}
	}

	if v := left {
		operations << Operation(v)
	}

	return operations
}

fn range_to_list(start rune, end rune) []rune {
	mut start_code := int(start)
	mut end_code := int(end)

	if start_code > end_code {
		start_code, end_code = end_code, start_code
	}

	mut characters := []rune{}

	for code in start_code .. end_code + 1 {
		characters << rune(code)
	}

	return characters
}

fn evaluate(text string, ops Set[[]Operation], state ArgState) string {
	mut current_text := text
	mut characters := []rune{}

	for op in ops.value {
		match state {
			.delete {
				if !ops.complement {
					match op {
						rune {
							current_text = current_text.replace(op.str(), '')
						}
						Range {
							for ch in range_to_list(op.start, op.end) {
								current_text = current_text.replace(ch.str(), '')
							}
						}
					}
				} else {
					match op {
						rune {
							characters << op
						}
						Range {
							for ch in range_to_list(op.start, op.end) {
								characters << ch
							}
						}
					}
				}
			}
			.squeeze {
				match op {
					rune {
						characters << op
					}
					Range {
						for ch in range_to_list(op.start, op.end) {
							characters << ch
						}
					}
				}
			}
		}
	}

	if characters.len > 0 {
		mut out := ''

		match state {
			.delete {
				for ch in current_text.runes() {
					if characters.contains(ch) {
						out += ch
					}
				}
			}
			.squeeze {
				mut current := ?rune(none)
				for ch in current_text.runes() {
					mut within := characters.contains(ch)
					within = if ops.complement { !within } else { within }

					if within {
						if c := current {
							if c != ch {
								out += c
							}
						}

						current = ch
					} else {
						if c := current {
							out += c
							current = none
						}

						out += ch
					}
				}

				if c := current {
					out += c
				}
			}
		}

		return out
	}

	return current_text
}

fn main() {
	args := arguments()[1..]

	mut values := []string{}
	mut deleting := []Set[string]{}
	mut squeezing := []Set[string]{}

	mut complement := false
	mut state := ?ArgState(none)

	for arg in args {
		if arg.starts_with('-') {
			for ch in arg.runes() {
				match ch {
					`-` {}
					`c` {
						complement = true
					}
					`d` {
						state = ArgState.delete
					}
					`s` {
						state = ArgState.squeeze
					}
					else {
						eprintln('Invalid argument entered ${ch}')
						return
					}
				}
			}
		} else {
			if current := state {
				match current {
					.delete {
						deleting << Set[string]{
							value:      arg
							complement: complement
						}
					}
					.squeeze {
						squeezing << Set[string]{
							value:      arg
							complement: complement
						}
					}
				}

				state = none
				complement = false
			} else {
				values << arg
				complement = false
			}
		}
	}

	if values.len <= 0 {
		eprintln('Please enter an input string')
		return
	}

	converted_deleting := deleting.map(|value| Set[[]Operation]{
		value:      convert_str_to_operations(value.value)
		complement: value.complement
	})

	converted_squeezing := squeezing.map(|value| Set[[]Operation]{
		value:      convert_str_to_operations(value.value)
		complement: value.complement
	})

	mut value := values[0]

	for x in converted_deleting {
		value = evaluate(value, x, .delete)
	}

	for x in converted_squeezing {
		value = evaluate(value, x, .squeeze)
	}

	println(value)
}
