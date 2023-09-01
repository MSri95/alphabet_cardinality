size=$1

inputFile="map_ParE2.tsv"
outputFile="output/output_ParE2_topPres_"$size
alphFile="alphabet_ParE2_topPres_"$size
subInputFile="input_sub_ParE2_topPres_"$size
antipodFile="antipodal_seqs_ParE2_topPres_"$size
tmpFile="tmp_out_ParE2_topPres_"$size
echo -n > $outputFile

# generate min(all_possible_alphabets_of_given_size, 5000) alphabets of a given size
echo "generating alphabets..."
python3 gen_alphs_empirical.py $size 5000 $inputFile $alphFile E L K Q I P N W S
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
