i=$1
c=$2
size=$3

inputFile="RMF_lands/RMF_L=4_"$i"_c="$c".txt"
outputFile="output/output_RMF_L=4_"$i"_c="$c"_"$size
alphFile="alphabet_RMF_L=4_"$i"_c="$c"_"$size
subInputFile="input_sub_RMF_L=4_"$i"_c="$c"_"$size
antipodFile="antipodal_seqs_RMF_L=4_"$i"_c="$c"_"$size
tmpFile="tmp_out_RMF_L=4_"$i"_c="$c"_"$size
echo -n > $outputFile

# generate min(all_possible_alphabets_of_given_size, 5000) alphabets of a given size
echo "generating alphabets..."
python3 gen_alphs_RMF.py $size 5000 $inputFile $alphFile 
echo
echo "counting the paths..."
while read alphabet; do
	echo $alphabet
	python3 gen_input.py $inputFile $alphabet $subInputFile $antipodFile
	./enumerate_all_paths $subInputFile $alphabet $antipodFile $tmpFile
	echo -n $size $alphabet >> $outputFile
	echo -n " " >> $outputFile
	cat $tmpFile >> $outputFile
done < $alphFile
echo "done"

sed -i 's/ /\t/g' $outputFile

rm $alphFile
rm $subInputFile
rm $antipodFile
rm $tmpFile