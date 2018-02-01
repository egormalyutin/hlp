#!/bin/bash
if [[ $1 == *"build"* ]] || [[ $2 == *"build"* ]]; then
	mkdir build
	cp *.lua build 
	echo 'Built!'
fi

if [[ $1 == *"watch"* ]] || [[ $2 == *"watch"* ]]; then
	echo 'Starting watch!'
	chokidar '**/*.moon' -c 'moonc {path}'
fi
