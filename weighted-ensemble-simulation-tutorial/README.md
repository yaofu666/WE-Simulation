# WESTPA Manual

WESTPA (Weighted Ensemble Simulation Toolkit with Parallelization and Analysis) is a software toolkit designed for the weighted ensemble simulation of molecular systems. It focuses on the efficient parallelization of calculations to facilitate the study of rare molecular events. Compatible with various molecular dynamics and Monte Carlo simulation engines, WESTPA provides tools for both the execution and analysis of simulations. Its primary goal is to help users simulate rare events and extract kinetic information from these events with precision and efficiency.

- [Spike Simulation Scripts](https://github.com/shirleyahn/we_scripts)

## Installation

Before installing WESTPA, we recommend looking at the [Anaconda tutorial](https://github.com/tsztain/SztainLab/blob/main/computational_basics/anaconda.md) to first install Anaconda.
After installing Anaconda, create and activate a new Python environment by running

```bash
conda create -n westpa python=3.9
conda activate westpa
```

Then, install WESTPA either through conda-forge or pip:

```bash
conda install -c conda-forge westpa
# OR
python -m pip install westpa
```

## WESTPA File Structure

- CONFIG: contains files needed to start the simulation for each segment/walker
  - prod.in: file for AMBER production run
  - prod_init.in: file for starting AMBER production run
  - [filename].pdb: a PDB file used in comparing simulations and calculating progress coordinate
- bstates: contains initial starting structures (basis states) for the WE simulation
  - [n].rst: n represents 0 through however many basis states there are (ex: 0-63)
  - [n].prmtop: n represents 0 through however many basis states there are (ex: 0-63)
- tstate_file: lists the target state boundary conditions
- BASIS_STATES: lists probabilities/weights of basis states
- analysis.cpptraj: CPPTRAJ input file used during runseg.sh to extract progress coordinates and auxiliary data at each iteration
- aux.cpptraj: CPPTRAJ input file used during runseg.sh to compute auxiliary observables for each segment; these are saved to west.h5 as auxiliary data for later analysis and are not used as progress coordinates
- env.sh: sets up the computing environment
- get_pcoord.sh: extracts the progress coordinate for the initial starting structures (only used for the very first iteration)
- init.sh: initializes the WE simulation (only used for the very first iteration) **RUN THIS FIRST BEFORE RUNWE_SLURM**
- node.sh: used to run the simulations for each node
- post_iter.sh: used at the post-processing step of each iteration (usually to tar and compress seg_logs and traj_segs)
- runseg.sh: used to run each segment/walker at each iteration
- runwe_slurm.sh: script to submit on the supercomputer cluster to execute the WE simulation
- west.cfg: configuration file for the WE simulation that sets up the number of progress coordinates, iterations, etc.

## Templates

The `templates` folder contains WESTPA folders that can be copied, according to the WESTPA strategy.
- template 0: An up to date template for a WESTPA simulation with a 2D progress coordinate and minimal adaptive binning (MAB). 


## Running WESTPA on Great Lakes

If this is your first weighted ensemble (WE) simulation, we recommend starting with the walkthrough in `WESTPA/templates/jason_template_westpa_tutorial.pdf` and using `template0`.

### 1. Copy the template to your working directory

Use a working directory under `/scratch` or under Turbo. Please keep simulation out of your home
directory, which only has an 80 GB quota.

Replace `/scratch/your_project/your_we_run` with the full path to your working directory on Great Lakes.

```bash
workdir="/scratch/your_project/your_we_run"

~/SztainLab/WESTPA/scripts/copy_prmtop_rst.sh \
    -b ~/SztainLab/WESTPA/templates/template0 \
    -c "$workdir"
```

Once the copy is complete, change to your working directory:

```bash
cd "$workdir"
```

### 2. Update the input files

Open `TODO.md`  and follow the instructions to update the input files for your simulation.

### 3. Initialize the simulation

From your working directory, run:

```bash
sh init.sh
```

Check that initialization finishes without errors before submitting the job.

### 4. Submit the job

From the same directory, submit the job to Slurm:

```bash
sbatch runwe_slurm.sh
```

