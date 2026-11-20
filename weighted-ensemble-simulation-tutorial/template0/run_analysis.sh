w_pdist -W west.h5 --o pdist.h5
plothist evolution pdist.h5 "0::ntl9_rmsd" -o ntl9_rmsd.pdf
plothist average pdist.h5 "0::ntl9_rmsd" -o ntl9_rmsd_average.pdf
