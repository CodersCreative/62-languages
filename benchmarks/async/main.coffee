worker = (id) -> 
  sum = 0;
  i = 0;
  
  while i < 500000
    sum += i * i;
    i += 1;

  console.log "task #{id} = #{sum}"

main = ->
  tasks = []

  for i in [0..64]
    tasks.push(worker(i))

  await Promise.all(tasks)
  console.log("all tasks finished");


main();
