for size in $(seq 3 20); do
	sbatch -t 1-00 --wrap="sh inner_loop_ParE2.sh $size"
done