#!/bin/bash
#SBATCH --time=25:15:00             # Time limit for the job (REQUIRED).
#SBATCH --job-name=batch2-ss_out_2_csv      # Job name
#SBATCH --nodes=1               # Number of nodes to allocate. Same as SBATCH -N (Don't use this option for mpi jobs)
#SBATCH --ntasks=64                  # Number of cores for the job. Same as SBATCH -n 1
#SBATCH --mem=128g
#SBATCH --partition=normal          # Partition/queue to run the job in. (REQUIRED)
#SBATCH -e slurm-ss-%j.err             # Error file for this job.
#SBATCH -o slurm-ss-%j.out             # Output file for this job.
#SBATCH -A xxx       # Project allocation account name (REQUIRED)
#SBATCH --mail-type ALL         # Send email when job starts/ends
#SBATCH --mail-user xxx@xxx   # Where email is sent to (optional)

module load Miniconda3
conda init
source ~/.bashrc
conda activate py310

# $1 is the location of the out-folders.
./ss_out_2_csv_v2.sh "$1" >> csv-log.out
