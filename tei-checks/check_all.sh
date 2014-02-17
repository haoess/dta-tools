#!/bin/bash 
# applies every script (has to be given via parameter) to all xml-files in the current folder
# if a script failes the filename of the xml-file will be written to 'out.txt'
> out.txt
scripts=("$@") 
for i in *.xml 
do
	echo $i
	for arg in "${scripts[@]}"; do
		echo $arg
		if (perl $arg $i)
			then
				echo $i' '$arg >> out.txt
		fi
	done
done
echo "done" >> out.txt

