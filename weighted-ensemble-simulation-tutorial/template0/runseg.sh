#!/bin/bash

if [ -n "$SEG_DEBUG" ] ; then
  set -x
  env | sort
fi

cd $WEST_SIM_ROOT
mkdir -pv $WEST_CURRENT_SEG_DATA_REF
cd $WEST_CURRENT_SEG_DATA_REF

cp $WEST_SIM_ROOT/analysis.cpptraj .
cp $WEST_SIM_ROOT/aux.cpptraj .

if [ "$WEST_CURRENT_SEG_INITPOINT_TYPE" = "SEG_INITPOINT_CONTINUES" ]; then
  sed "s/RAND/$WEST_RAND16/g" $WEST_SIM_ROOT/CONFIG/prod.in > prod.in
  cp $WEST_PARENT_DATA_REF/seg.rst ./parent.rst
  cp $WEST_PARENT_DATA_REF/parent.prmtop ./parent.prmtop
elif [ "$WEST_CURRENT_SEG_INITPOINT_TYPE" = "SEG_INITPOINT_NEWTRAJ" ]; then
  sed "s/RAND/$WEST_RAND16/g" $WEST_SIM_ROOT/CONFIG/prod_init.in > prod.in
  cp $WEST_PARENT_DATA_REF.rst ./parent.rst
  cp $WEST_PARENT_DATA_REF.prmtop ./parent.prmtop
fi

export CUDA_DEVICES=(`echo $CUDA_VISIBLE_DEVICES_ALLOCATED | tr , ' '`)
export CUDA_VISIBLE_DEVICES=${CUDA_DEVICES[$WM_PROCESS_INDEX]}

echo "RUNSEG.SH: CUDA_VISIBLE_DEVICES_ALLOCATED = " $CUDA_VISIBLE_DEVICES_ALLOCATED
echo "RUNSEG.SH: WM_PROCESS_INDEX = " $WM_PROCESS_INDEX
echo "RUNSEG.SH: CUDA_VISIBLE_DEVICES = " $CUDA_VISIBLE_DEVICES

$PMEMD -O -p parent.prmtop -i prod.in -c parent.rst -o seg.out -inf seg.nfo -l seg.log -x seg.nc -r seg.rst || exit 1

$CPPTRAJ.cuda -i analysis.cpptraj > analysis.log || exit 1
$CPPTRAJ.cuda -i aux.cpptraj      > aux.log      || exit 1

# The name between WEST_ and _RETURN must match the uppercase name of the corresponding pcoord or aux_pcoord in west.cfg
# For example: pcoord -> WEST_PCOORD_RETURN; rg -> WEST_RG_RETURN

paste <(tail -n +2 rmsd.dat | awk '{print $2}') \
      <(tail -n +2 Q.dat    | awk '{print $2}') > $WEST_PCOORD_RETURN

cat rg.dat | tail -n +2 | awk {'print $2'} > $WEST_RG_RETURN


# Remove water and ions from seg.nc (if needed); BUT keep seg.rst unchanged.
cat << EOF > strip.cpptraj
parm parent.prmtop
trajin seg.nc
autoimage
strip :WAT,Na+,Cl-
trajout seg_dry.nc
run
EOF

$CPPTRAJ.cuda -i strip.cpptraj > strip.log && mv seg_dry.nc seg.nc || exit 1

rm -f prod.in analysis.cpptraj aux.cpptraj strip.cpptraj


