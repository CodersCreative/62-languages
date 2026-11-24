hyperfine \
  "revo main.rv" \
  "calibre run --backend jit main.cal" \
  "calibre run main.cal" \
  "coffee main.coffee" \
  "ocaml main.ml" \
  "v run main.v" \
  "elixir main.exs" \
  "v main.v && ./main" \
  --warmup 3
