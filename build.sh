#!/bin/bash
if [[ $1 == *"clean"* ]]; then
	echo 'Cleaning example stuff...'
	rm examples main.*
	echo "Success!"
fi

if [[ $1 == *"watch"* ]]; then
	echo 'Starting watch!'
	chokidar '**/*.moon' -c 'moonc {path}'
fi

