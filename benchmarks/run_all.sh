for dir in pi fib async; do
  (cd "$dir" && sh run.sh) || exit 1
done
