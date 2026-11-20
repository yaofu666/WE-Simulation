#!/bin/bash

if [ -n "$SEG_DEBUG" ] ; then
  set -x
  env | sort
fi

cd $WEST_SIM_ROOT

RMSD=$(mktemp)
RG=$(mktemp)
Q=$(mktemp)

COMMAND="           parm ${WEST_STRUCT_DATA_REF}.prmtop \n"
COMMAND="${COMMAND} trajin ${WEST_STRUCT_DATA_REF}.rst \n"
COMMAND="${COMMAND} autoimage \n"
COMMAND="${COMMAND} parm $WEST_SIM_ROOT/CONFIG/1_ntl9_1-56.prmtop [natparm] \n"
COMMAND="${COMMAND} reference $WEST_SIM_ROOT/CONFIG/1_ntl9_1-56.rst parm [natparm] [nat] \n"

# pcoord 1: CA RMSD
COMMAND="${COMMAND} rms RMSD :1-56@CA ref [nat] out $RMSD \n"

# pcoord 2: Q
COMMAND="${COMMAND} nativecontacts name NC :1-56@CA ref [nat] distance 8.0 resoffset 4 byresidue noimage \n"

# aux pcoord: Rg
COMMAND="${COMMAND} radgyr RG :1-56&!@H= mass nomax out $RG \n"

COMMAND="${COMMAND} run \n"

COMMAND="${COMMAND} Q = NC[native] / 67 \n"
COMMAND="${COMMAND} writedata $Q Q noheader \n"
COMMAND="${COMMAND} quit \n"

echo -e "${COMMAND}" | $CPPTRAJ

# Store RMSD and Q values in the pcoord variable
paste <(tail -n 1 $RMSD | awk '{print $2}') \
      <(tail -n 1 $Q    | awk '{print $2}') > $WEST_PCOORD_RETURN


if [ -n "$WEST_RG_RETURN" ] ; then
    tail -n 1 $RG | awk '{print $2}' > $WEST_RG_RETURN
fi


rm -f $RMSD $RG $Q 

if [ -n "$SEG_DEBUG" ] ; then
    head -v $WEST_PCOORD_RETURN
fi


