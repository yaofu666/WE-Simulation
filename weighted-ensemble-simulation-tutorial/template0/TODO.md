# WESTPA Simulation template 0
This WE simulation template is designed to study the unfolding process of NTL9 starting from its folded structure. It uses two progress coordinates to monitor the unfolding process and the MAB (Minimal Adaptive Binning) scheme to automatically adjust bin boundaries during the simulation. No target state is defined, and water molecules are excluded from the saved trajectories.

Once you have your basis states ready (.prmtop and .rst), you can begin editing this template folder to match your simulation. This markdown file will help you set up a WESTPA simulation run by listing all the TODOs.


## 1. Create bstates folder and move .prmtop and .rst files here

The first thing you need to do is to create a bstates folder:

```bash
mkdir bstates
```
Then move your basis states to the `bstates` folder. Rename each state accordingly: `0.prmtop` and `0.rst`, `1.prmtop` and `1.rst`, etc.

## 2. Edit BASIS_STATES

In the `BASIS_STATES` file, you will need to specify each basis states file and the weight you want to assign to each. In most cases, the basis states will get equal weights, resulting in a sum of 1.0.

In this example, there is only 1 basis state(folded protein), so we only have 0.prmtop. 

## 3. Move your reference PDB to the CONFIG folder

If you have a reference PDB(or .prmtop +.rst) that you are constantly comparing the simulation to in order to calculate the progress coordinate, then move the PDB(or .prmtop +.rst) to the `CONFIG` folder.

The `CONFIG` folder will also contain `prod_init.in` and `prod.in`, responsible for the pmemd run of each segment. These runs are set to 100 ps.

## 4. Edit analysis.cpptraj and aux.cpptraj to fit your needs, here we have 2 Progress Coordinates and 1 Auxiliary Progress Coordinate

The `analysis.cpptraj` and `aux.cpptraj` are files that are copied to each segment during WESTPA, and used by CPPTRAJ to calculate the pcoord/aux_pcoord of the segment run.

**Remember to replace the paths of the reference file if you have one.**

In this example, the RMSD of protein residues 1–56 is calculated using Cα atoms and written to `rmsd.dat`. The fraction of native contacts (Q) is calculated using Cα atoms of the same residues, with an 8.0 Å distance cutoff and a minimum residue separation of 4, and written to `Q.dat`. The radius of gyration (Rg) is calculated using the non hydrogen atoms of residues 1–56, with mass weighting, and written to `rg.dat`.

If you use different progress coordinates or atom/residue selections, make sure to adjust the script accordingly for your system. It is always good to test the CPPTRAJ script on a short trajectory first before incorporating it into your WE simulation setup.

## 5. Edit get_pcoord.sh to reflect analysis.cpptraj and aux.cpptraj

Like `analysis.cpptraj`, `get_pcoord.sh` also calculates the progress coordinates. The distinct difference is that `get_pcoord.sh` is only called during initialization of the WESTPA protocol.

Make sure to edit `get_pcoord.sh` so that it is calculating the progress coordinates in the same way as `analysis.cpptraj`.

Note: If you use more than two progress coordinates, add another `mktemp` line following the same pattern used for `RMSD` and `Q`, and make sure to include the additional coordinate in `$WEST_PCOORD_RETURN`. Keep in mind that using three progress coordinates can significantly increase the computational cost of WE simulations.

## 6. Setting env.sh

`env.sh` is responsible for setting up environment variables and paths. For example, if you are running WESTPA on a new machine, you need to make sure that it can use the GPU, find AMBER, and have access to your conda environment so that it can run WESTPA.

Set the PYTHONPATH to find the bin and site-packages of your WESTPA conda environment.

## 7. Setting tstate.file

`tstate.file` is a very simple file that includes the target definition of the progress coordinates. Modify accordingly.

No target state is needed for this unfolding simulation, as we want both pcoords to increase as much as possible. But for example for folding simulations, you can define a target state using both pcoords, e.g., 'fold 1.0 0.9'.


## 8. Edit runseg.sh

The `runseg.sh` script is executed for each WE segment. It runs pmemd, copies the necessary files, runs CPPTRAJ using `analysis.cpptraj` and `aux.cpptraj`, and passes the calculated progress coordinates (RMSD and Q) and auxiliary data (Rg) to WESTPA. In this example, these values are read from rmsd.dat, Q.dat, and rg.dat, respectively.

Make sure to update the file names and commands if you change, add, or remove progress coordinates or auxiliary data.

Make sure to update the file names and commands if you change, add, or remove progress coordinates.

Note: To stop a running WE simulation relatively safely, you can rename `runseg.sh` to something like `runseg_stop.sh`. Allow WESTPA to stop, then rename it back to `runseg.sh` before restarting the simulation.


## 9. Modify west.cfg

The west.cfg file contains important settings for the progress coordinates and binning scheme. Make sure pcoord_ndim matches the number of progress coordinates used in your simulation.

In this example, we use 2D rectilinear binning. You can adjust the bin boundaries and spacing as needed, even between runs. Here we use MAB (Minimal Adaptive Binning), which automatically adjusts the bin boundaries based on the progress coordinates sampled during the simulation.

Note: west.cfg is a YAML file, so incorrect indentation can cause errors. Make sure the indentation is consistent and properly formatted.

## 10. Edit runwe_slurm.sh

The `runwe_slurm.sh` file is for submitting to UM GreatLake slurm:

```bash
sbatch runwe_slurm.sh
```

Edit the #SBATCH parameters to suit the slurm job parameters. Make sure the environment variables are correct as well. Next, set the number of GPU per node based on the slurm job parameters.

## Files that will remain mostly the same

There are also some files that will mostly be the same regarding of simulation and system differences.
These include `init.sh`, `node.sh`, `post_iter.sh`.


