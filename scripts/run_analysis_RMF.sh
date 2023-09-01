for i in $(seq 100); do
	for c in "0.125" "0.25" "0.4" "1.0"; do
		for size in $(seq 4 20); do
			sbatch -t 1-00 --wrap="sh inner_loop_RMF.sh $i $c $size"
		done
	done
done