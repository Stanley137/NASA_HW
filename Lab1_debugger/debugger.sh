#!/bin/bash
# echo $1 $2 $3 $4
#set -x # debugging
# argument
arg_gen=$1
ac_code=$2
wa_code=$3
times=$4
# compile
gcc $arg_gen -o gen
gcc $ac_code -o a
gcc $wa_code -o b
# test code
for (( i = 1; i < $times; i++ )); do
	./gen $i > in.txt
	ac_result=`cat ./in.txt | ./a` 
	wa_result=`cat ./in.txt | ./b`
	if [[ "$ac_result" != "$wa_result"  ]]; then
		echo "Test $i"
		echo "Input:"
		cat ./in.txt
		echo "--------------------"
		echo "Output of $ac_code"
		echo "--------------------"
		echo $ac_result | awk '{print $1"\n"$2}'
		echo "--------------------"
		echo "Output of $wa_code"
		echo "--------------------"
		echo $wa_result | awk '{print $1"\n"$2}'
		echo "--------------------"
	fi
done
