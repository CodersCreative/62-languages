import sync

fn worker(id int, mut wg sync.WaitGroup) {
	mut sum := i64(0)
	mut i := i64(0)

	for i < 500000 {
		sum += i * i
		i += 1
	}

	println('task ${id} = ${sum}')
	wg.done()
}

fn main() {
	mut wg := sync.new_waitgroup()

	for i in 0 .. 64 {
		wg.add(1)
		go worker(i, mut wg)
	}

	wg.wait()

	print('all tasks finished')
}
