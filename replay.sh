#!/bin/bash

set -e

# Created 2026-04-29 15:48:53

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.341"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08o/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.338

./xmlchange RUN_REFDATE=0031-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/u/home/igrooms/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100sh_e250r250nh_merged_modified_260317.nc

./xmlchange ROF2OCN_LIQ_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100_260306.nc

./xmlchange ICE_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange OCN_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange MASK_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./preview_namelists

./preview_namelists

./case.build

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/u/home/igrooms/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100sh_e250r250nh_merged_modified_260317.nc

./xmlchange ROF2OCN_LIQ_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100_260306.nc

./xmlchange ICE_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange OCN_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange MASK_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=20,STOP_N=2,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=20,STOP_N=2,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.submit

./case.submit

./xmlchange RESUBMIT=3

./xmlchange RESUBMIT=5

./xmlchange RESUBMIT=10

./case.submit

./xmlchange RESUBMIT=10

./xmlchange RESUBMIT=10,STOP_N=4

./case.submit

./xmlchange RESUBMIT=20

./case.submit

./xmlchange RESUBMIT=10

./xmlchange RESUBMIT=0

./xmlchange RESUBMIT=0,STOP_N=4

