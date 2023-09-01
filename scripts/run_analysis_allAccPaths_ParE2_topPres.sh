for size in $(seq 9 20); do
	sbatch -t 1-00 --wrap="sh inner_loop_ParE2_topPres.sh $size"
done