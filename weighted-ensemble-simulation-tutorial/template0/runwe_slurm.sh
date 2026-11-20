#!/bin/bash
#SBATCH --job-name=NTL9_1-56_unfold_2D
#SBATCH --nodes=2
#SBATCH --cpus-per-task=4
#SBATCH --gpus-per-node=4
#SBATCH --time=05-00:00:00
#SBATCH --output=/scratch/tsztain_root/tsztain0/shared_data/simulations_Yao/NTL9_1-56_unfolding/%x-%j.log
#SBATCH --account=tsztain_owned1
#SBATCH --partition=spgpu2
#SBATCH --mem=10G

set -x
cd $SLURM_SUBMIT_DIR
source ~/.bash_profile
export MY_SPECTRUM_OPTIONS="--gpu"
export PATH=$PATH:$HOME/bin

source ~/.bash_profile
module purge
module load cuda/12.1.1
module load Chemistry
module load amber/24
module load gcc/13.2.0
conda activate /home/fuyao/.conda/envs/westpa_new
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export WEST_SIM_ROOT=$SLURM_SUBMIT_DIR
# export PYTHONPATH=/home/fuyao/.conda/envs/westpa_new/lib/python3.11/site-packages:/home/fuyao/anaconda3/envs/WESTPA/bin

source env.sh || exit 1
env | sort

SERVER_INFO=$WEST_SIM_ROOT/west_zmq_info-$SLURM_JOBID.json

# set num_gpu_per_node 
num_gpu_per_node=4
rm -rf nodefilelist.txt
scontrol show hostname $SLURM_JOB_NODELIST > nodefilelist.txt

# start server
w_run --work-manager=zmq --n-workers=0 --zmq-mode=master --zmq-write-host-info=$SERVER_INFO --zmq-comm-mode=tcp &> west-$SLURM_JOBID-local.log &

# wait on host info file up to 1 min
for ((n=0; n<60; n++)); do
    if [ -e $SERVER_INFO ] ; then
        echo "== server info file $SERVER_INFO =="
        cat $SERVER_INFO
        break
    fi
    sleep 1
done

# exit if host info file doesn't appear in one minute
if ! [ -e $SERVER_INFO ] ; then
    echo 'server failed to start'
    exit 1
fi
export CUDA_VISIBLE_DEVICES=0,1,2,3
for node in $(cat nodefilelist.txt); do
    ssh -o StrictHostKeyChecking=no $node $PWD/node.sh $SLURM_SUBMIT_DIR $SLURM_JOBID $node $CUDA_VISIBLE_DEVICES --work-manager=zmq --n-workers=$num_gpu_per_node --zmq-mode=client --zmq-read-host-info=$SERVER_INFO --zmq-comm-mode=tcp &
done
wait