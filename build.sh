#!/bin/bash
if [[ $1 == *"clean"* ]]; then
	echo 'Cleaning example stuff...'
	rm -rf examples/
	rm main.*
	rm config.ld
	rm -rf docs/
	echo "Success!"
fi

if [[ $1 == *"watch"* ]]; then
	echo 'Starting watch!'
	chokidar '(asset|event|finder|locale|ps)/*.moon' -c 'moonc {path}'
fi
