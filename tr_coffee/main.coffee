ArgState = Object.freeze(
  Delete: 0
  Squeeze: 1
  None: 2
)

class Operation
  constructor: (@value, @to) ->

class Set
  constructor: (@value, @complement) ->

convert_str_to_operations = (value) ->
  operations = []
  in_range = false
  left = null

  for ch in value
    if left?
      if ch == '-'
        in_range = true
      else if in_range
        operations.push new Operation left, ch
        in_range = false
        left = null
      else
        operations.push new Operation left, null
        left = ch
    else
      left = ch

  if left?
    operations.push new Operation left, null

  return operations

evaluate = (text, ops, state) ->
  characters = []

  for i in [0..ops.value.length]
    op = ops.value[i]
    unless op?
      break

    if state == ArgState.Delete && !ops.complement
      if op.to?
        start = op.value.charCodeAt 0
        end = op.to.charCodeAt 0

        if start > end
          temp = start
          start = end
          end = temp

        for ch in [start..end]
          text = text.replace String.fromCharCode(ch), ''
      else
        text = text.replace op.value, ''
    else
      if op.to?
        start = op.value.charCodeAt 0
        end = op.to.charCodeAt 0

        if start > end
          temp = start
          start = end
          end = temp

        for ch in [start..end]
          characters.push String.fromCharCode ch
      else
        characters.push op.value

  if characters.length > 0
    out = ''

    switch state
      when ArgState.Delete
        for ch in text
          if ch in characters
            out += ch
      when ArgState.Squeeze
        current = null
        for ch in text
          within = ch in characters
          within = if ops.complement then !within else within

          if within
            if current?
              if current != ch
                out += current

            current = ch
          else
            if current?
              out += current
              current = null

            out += ch

    return out

  return text

main = ->
  args = process.argv[2..]

  values = []
  deleting = []
  squeezing = []

  complement = false
  state = ArgState.None

  for arg in args
    if arg.startsWith '-'
      for ch in arg
        switch ch
          when '-' then undefined
          when 'c' then complement = true
          when 'd' then state = ArgState.Delete
          when 's' then state = ArgState.Squeeze
          else
            console.error 'Invalid argument entered ', ch
            return
    else if state != ArgState.None
      switch state
        when ArgState.Delete then deleting.push new Set arg, complement
        else squeezing.push new Set arg, complement

      state = ArgState.None
      complement = false
    else
      values.push arg
      complement = false

  if values.length <= 0
    console.error 'Please enter an input string'
    return

  converted_deleting =
    new Set convert_str_to_operations(x.value), x.complement for x in deleting
  converted_squeezing =
    new Set convert_str_to_operations(x.value), x.complement for x in squeezing

  value = values[0]

  for op in converted_deleting
    value = evaluate value, op, ArgState.Delete

  for op in converted_squeezing
    value = evaluate value, op, ArgState.Squeeze

  console.log value

main()
