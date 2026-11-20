source ~/.bash_profile
module purge
module load cuda/12.1.1
module load Chemistry
module load amber/24
module load gcc/13.2.0

conda activate /home/fuyao/.conda/envs/westpa_new
export PATH=/home/fuyao/.conda/envs/westpa_new/bin:$PATH
unset PYTHONPATH

export MY_SPECTRUM_OPTIONS="--gpu"
export PATH=$PATH:$HOME/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

# Explicitly name our simulation root directory
if [[ -z "$WEST_SIM_ROOT" ]]; then
    export WEST_SIM_ROOT="$PWD"
fi

export SIM_NAME=$(basename $WEST_SIM_ROOT)
echo "simulation $SIM_NAME root is $WEST_SIM_ROOT"

export NODELOC=/scratch/tsztain_root/tsztain0/shared_data/simulations_Yao/NTL9_1-56_unfolding
export USE_LOCAL_SCRATCH=1

export WM_ZMQ_MASTER_HEARTBEAT=100
export WM_ZMQ_WORKER_HEARTBEAT=100
export WM_ZMQ_TIMEOUT_FACTOR=300
export BASH=$SWROOT/bin/bash
export PERL=$SWROOT/usr/bin/perl
export ZSH=$SWROOT/bin/zsh
export IFCONFIG=$SWROOT/bin/ifconfig
export CUT=$SWROOT/usr/bin/cut
export TR=$SWROOT/usr/bin/tr
export LN=$SWROOT/bin/ln
export CP=$SWROOT/bin/cp
export RM=$SWROOT/bin/rm
export SED=$SWROOT/bin/sed
export CAT=$SWROOT/bin/cat
export HEAD=$SWROOT/bin/head
export TAR=$SWROOT/bin/tar
export AWK=$SWROOT/usr/bin/awk
export PASTE=$SWROOT/usr/bin/paste
export GREP=$SWROOT/bin/grep
export SORT=$SWROOT/usr/bin/sort
export UNIQ=$SWROOT/usr/bin/uniq
export HEAD=$SWROOT/usr/bin/head
export MKDIR=$SWROOT/bin/mkdir
export ECHO=$SWROOT/bin/echo
export DATE=$SWROOT/bin/date
export SANDER=$AMBERHOME/bin/sander
export PMEMD=$AMBERHOME/bin/pmemd.cuda
export CPPTRAJ=$AMBERHOME/bin/cpptraj