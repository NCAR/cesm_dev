#!/bin/bash

set -e

# Created 2026-03-11 14:45:15

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.321"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_TYPE=startup

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100sh_e250r250nh_merged_260307.nc

