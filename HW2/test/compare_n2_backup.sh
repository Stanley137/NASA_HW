#!/bin/bash
# old
dir1=`find $1 | sed "s/${1}\///" | sort` # remove the dir1 string
dir2=`find $2 | sed "s/${2}\///" | sort` # remove the dir2 string
found=0
result_Arr=()
while IFS="" read -r line_1; do
	if [[ "$line_1" = "$1" ]]; then
		continue
	fi
	while IFS="" read -r line_2; do
		if [[ "$line_2" = "$2" ]]; then
			continue
		fi
		if [[ "$line_1" = "$line_2" ]]; then
			# echo "$line_1"
			# echo "$line_2"
			if [[ -L $1/$line_1 ]] || [[ -d $1/$line_1 ]]; then
				continue
			fi
				if [[ "${line_1:0:1}" = "." ]] && [[ $a_all_file -eq 0 ]]; then # not all files
					continue
				fi
			found=1
			# echo "$1/$line_1"
			# echo "$2/$line_2"
			return=`compare_files $1/$line_1 $2/$line_2`
			if [[ $return != "changed 0%" ]]; then
				result_Arr+=("$line_1")
				echo "$line_1: $return"
			fi
		fi
	done <<< "$dir2"
	if [[ $found -ne 1 ]]; then
		if [[ -f $1/$line_1 ]]; then
			echo "delete $line_1"
			result_Arr+=("$line_1")
		fi
	fi
	found=0
done <<< "$dir1"
echo "Start======="
found=0
while IFS="" read -r line_2; do
	if [[ "$line_2" = "$2" ]]; then
		continue
	fi
	while IFS="" read -r line_1; do
		if [[ "$line_1" = "$1" ]]; then
			continue
		fi
		if [[ "$line_1" = "$line_2" ]]; then
			if [[ "${line_1:0:1}" = "." ]] && [[ $a_all_file -eq 0 ]]; then # not all files
				continue
			fi
			found=1
		fi
	done <<< "$dir1"
	if [[ $found -eq 0 ]]; then
		result_Arr+=("$line_2")
		echo "create $line_2"
	fi
	found=0
done <<< "$dir2"
# sorted
sorted=$(printf "%s\n" "${result_Arr[@]}" | sort)
sorted_result=($sorted)
echo "START============" 
for line in "${sorted[@]}"; do
	echo "$line"
done