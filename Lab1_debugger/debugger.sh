#!/bin/bash

# echo $1 $2 $3 $4
#set -x # debugging
# argument
arg_gen=$1
ac_code=$2
wa_code=$3
times=$4
# compile and create file
touch in.txt
touch a.txt
touch b.txt
gcc $arg_gen -o gen
gcc $ac_code -o a
gcc $wa_code -o b

# permission
chmod +x gen
chmod +x a
chmod +x b
chmod +rwx a.txt
chmod +rwx b.txt
chmod +rwx in.txt

# test code
for (( i = 1; i <= $times; i++ )); do
	./gen $i > in.txt
	cat ./in.txt | ./a > a.txt
       	cat ./in.txt | ./b > b.txt
	cmp -s a.txt b.txt
	if [[ $? -ne 0 ]]; then
		echo "Test $i"
		echo "Input:"
		cat ./in.txt
		echo "--------------------"
		echo "Output of $ac_code"
		echo "--------------------"
		cat ./a.txt
		echo "--------------------"
		echo "Output of $wa_code"
		echo "-------------------"
		cat ./b.txt
		echo "--------------------"
	fi
done
