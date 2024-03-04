#!/bin/bash	
# set -x
# set -e
## --help usage
usage(){
	echo "usage: ./compare.sh [OPTION] <PATH A> <PATH B>"
	echo "options:"
	echo "-a: compare hidden files instead of ignoring them"
	echo "-h: output information about compare.sh"
	echo "-l: treat symlinks as files instead of ignoring them"
	echo "-n <EXP>: compare only files whose paths follow the REGEX <EXP>"
	echo "-r: compare directories recursively"
	exit 1
}

# Parse argument
while getopts "n:ahrl" option; do
	case "$option" in
		h)
			usage
			;;
		l)	
			l_as_file=1
			;;
		r)
			r_recursive=1
			;;
		a)
			a_all_file=1
			;;
		n)
			n_regular=1
			exp_str="$OPTARG"
			;;
		:)
			usage
			;;
		?)
			usage
			;;
	esac
done

# remove the options
shift $((OPTIND	 - 1))
# echo "$1" 
# echo "$2"
p1=`echo "$1" | sed 's/\/\+/\//g'`
p2=`echo "$2" | sed 's/\/\+/\//g'`
# echo "$p1"
# echo "$p2"
# check whether has others token
if [[ $# -ne 2 ]]; then
	usage
fi
# check -r 
if [[ $r_recursive -eq 1 ]]; then
	# The directory not exist
	if [[ ! -d $p1 ]] || [[ ! -d $p2 ]]; then
		usage
	fi
elif [[ $r_recursive -ne 1 ]]; then 
	# the paramater are not file
	if [[ -d $p1 ]] || [[ -d $p2 ]]; then
		usage
	fi
	# exist or not
	if [[ ! -e $p1 ]] || [[ ! -e $p2 ]]; then
		usage
	fi
	# link or not
	if [[ -h $p1 || -h $p2 ]] && [[ $l_as_file -ne 1 ]]; then
		usage
	fi 
fi

# # link as file false
# if [[ $l_as_file -ne 1 ]]; then
# 	# check directory
# 	if [[ $r_recursive -eq 1 ]]; then
# 		if [[ ! -d $p1 ]] || [[ ! -d $p2 ]]; then
# 			usage
# 		fi
# 	# check file
# 	elif [[ $r_recursive -ne 1 ]]; then
# 		if [[ ! -f $p1 ]] || [[ ! -f $p2 ]]; then
# 			usage
# 		fi
# 	fi
# fi
# # link exist
# if [[ $l_as_file -eq 1 ]]; then
# 	if [[ ! -e $p1 ]] || [[ ! -e $p2 ]]; then
# 		usage
# 	fi
# fi

# check -a and -n, -r
# a,n must come with r
if [[ $a_all_file -eq 1 ]]; then
	if [[ $r_recursive -ne 1 ]]; then
		usage
	fi
elif [[ $n_regular -eq 1 ]]; then
	if [[ $r_recursive -ne 1 ]]; then
		usage
	fi
fi


compare_files(){
	first_result=`diff $1 $2`
	if [[ "Binary files $1 and $2 differ" = "$first_result" ]]; then
		echo "changed 100%"
	else
		result=`diff -d $1 $2`
		remove=`echo "$result" | grep "^< " -c`
		add=`echo "$result" | grep "^> " -c`
		all=`grep -v "^*" $1 | wc -l` # all lines include \n, using cat will lost the number
		save=$(($all-$remove))
		# max
		if [[ $remove -gt $add ]]; then
			n=$(($remove))
		else
			n=$(($add))	
		fi
		num=$(($n*100/($n+save)))
		# echo "$all"
		# echo "$remove $add $save"
		echo "changed $num%"
	fi
}

# Compare file without -l
if [[ ! -h $p1 ]] && [[ ! -h $p2 ]] && [[ $r_recursive -ne 1 ]] && [[ $l_as_file -ne 1 ]]; then
	compare_files "$p1" "$p2"
	exit 1
fi

# Compare file with -l
if [[ $r_recursive -ne 1 ]] && [[ $l_as_file -eq 1 ]]; then
	if [[ -h $p1 && -h $p2 ]]; then
		link1=`readlink $p1`
		link2=`readlink $p2`
		if [[ "$link1" != "$link2" ]]; then
			echo "changed 100%"
		fi
	elif [[ -h $p1 && ! -h $p2 ]] || [[ ! -h $p1 && -h $p2 ]];then
		echo "changed 100%"
	else
		compare_files "$p1" "$p2"
	fi
	exit 1
fi

# -r, -l , -a operation
if [[ -d $p1 ]] && [[ -d $p2 ]] && [[ $r_recursive -eq 1 ]]; then
	diff_result=`diff -rq $p1 $p2`
	# echo "$diff_result"
	# echo "======="
	while IFS="" read -r line; do
		Check_File=`echo "$line" | awk '{print $1}'`
		if [[ "$Check_File" = "Files" ]]; then
			file1=`echo "$line" | awk '{print $2}'`  # dir1/path
			file2=`echo "$line" | awk '{print $4}'`  # dir2/path
			# echo "$file1"
			# echo "$file2"	
			# file1=`echo $file1 | sed -e "s/${1}\///"`
			file1=${file1#$p1/} # path/
			file2=${file2#$p2/} # path/

			# deal with unseen file
			if [[ "$file1" =~ ^\..* || "$file1" =~ .*\/\..* ]] && [[ $a_all_file -eq 0 ]]; then
				# check whether hidden directory
				continue
			fi
			## process with -n <regex>
			if [[ $n_regular -eq 1 ]]; then
				if [[ ! "$file1" =~ "$exp_str" ]];then
					continue
				fi
			fi
			# link as file or not
			if [[ $l_as_file -eq 1 ]]; then
				## all all links
				if [[ -L $p1/$file1 && -L $p2/$file2 ]]; then
					link1=`readlink $p1/$file1`
					link2=`readlink $p2/$file2`
					# deal with link content
					if [[ "$link1" != "$link2" ]]; then
						echo "$file1: changed 100%"
					fi
					continue
				fi
				## one is link
				if [[ -f $p1/$file1 && -L $p2/$file2 ]] || [[ -L $p1/$file1 && -f $p2/$file2 ]]; then
					echo "$file1: changed 100%"
					continue
				fi
			else
				# deal with link
				if [[ -h $p1/$file1 ]]; then
					continue
				fi
				# deal with file and link
				if [[ -f $p1/$file1 && -h $p2/$file2 ]]; then
					echo "delete $file1"
					continue
				fi
			fi

			cmp_result=`compare_files $p1/$file1 $p2/$file2`
			if [[ "$cmp_result" != "changed 100%" ]]; then
				echo "$file1: $cmp_result"
			else
				echo "$file1: changed 100%"
			fi

		elif [[ "$Check_File" = "File" ]]; then # which means one of them are directory
			# deal with -l
			if [[ $l_as_file -eq 1 ]]; then
				file1=`echo "$line" | awk '{print $2}'`  # dir1/path
				file2=`echo "$line" | awk '{print $8}'`  # dir2/path
				# echo "$file1"
				# echo "$file2"	
					# file1=`echo $file1 | sed -e "s/${1}\///"`
				file1=${file1#$p1/} # path/
				file2=${file2#$p2/} # path/
				## process with -n <regex>
				if [[ $n_regular -eq 1 ]]; then
					if [[ ! "$file1" =~ "$exp_str" ]];then
						continue
					fi
				fi
				# deal with unseen file
				if [[ "$file1" =~ ^\..* || "$file1" =~ .*\/\..* ]] && [[ $a_all_file -eq 0 ]]; then
					# check whether hidden directory
					continue
				fi
				link1=`readlink $p1/$file1`
				link2=`readlink $p2/$file2`
				# deal with link content
				if [[ "$link1" != "$link2" ]]; then
					echo "$file1: changed 100%"
				fi
			fi
		elif [[ "$Check_File" = "Only" ]]; then
			which_dir=`echo "$line" | awk '{print $3}'`
			if [[ "$which_dir" = "$1:" ]]; then
				file1=`echo "$line" | awk '{print $4}'`
				# deal with unseen file
				if [[ "$file1" =~ ^\..* || "$file1" =~ .*\/\..* ]] && [[ $a_all_file -eq 0 ]]; then
					# check whether hidden directory
					continue
				fi
				rel_dir=`echo "$which_dir" | sed 's/\/\+/\//g'`
				rel_dir=${rel_dir#$p1}
				rel_dir=${rel_dir%:}
				rel_dir=${rel_dir:1}
				file_path="$rel_dir$file1"
				## process with -n <regex>
				if [[ $n_regular -eq 1 ]]; then
					if [[ ! "$file_path" =~ "$exp_str" ]];then
						continue
					fi
				fi
				# echo "$file_path"
				echo "delete $file_path"
			elif [[ "$which_dir" = "$2:" ]]; then
				file2=`echo "$line" | awk '{print $4}'`
				# deal with unseen file
				if [[ "$file2" =~ ^\..* || "$file2" =~ .*\/\..* ]] && [[ $a_all_file -eq 0 ]]; then
					# check whether hidden directory
					continue
				fi
				rel_dir=`echo "$which_dir" | sed 's/\/\+/\//g'`
				rel_dir=${rel_dir#$p2}
				rel_dir=${rel_dir%:}
				rel_dir=${rel_dir:1}
				file_path="$rel_dir$file2"
				## process with -n <regex>
				if [[ $n_regular -eq 1 ]]; then
					if [[ ! "$file_path" =~ "$exp_str" ]];then
						continue
					fi
				fi
				echo "create $file_path"
			fi
		fi
	done <<< "$diff_result"	
	exit 1
fi