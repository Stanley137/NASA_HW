#!/usr/bin/env bash
./sample.sh
for i in `ls output`; do
	if [[ -z `diff sample_output/$i output/$i` ]]; then
		echo -e "$i: \033[0;32mAccept\033[0m"
	else
		echo -e "$i: \033[0;31mWrong Answer\033[0m"
	fi
done
