python3 ./GenerateSbatchScriptAuto.py $1 $2 $3 $4> slurm_tmp.sh
sbatch slurm_tmp.sh
