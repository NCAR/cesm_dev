#!/bin/bash

set -e

# Created 2026-03-20 15:46:26

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.328"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha08b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.328 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange MASK_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.n

./xmlchange OCN_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange MASK_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange OCN_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange ICE_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange OF2OCN_LIQ_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100_260306.nc

./xmlchange ROF2OCN_LIQ_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100_260306.nc

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/u/home/igrooms/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100sh_e250r250nh_merged_modified_260317.nc

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./check_case

./case.submit

