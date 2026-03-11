#!/bin/bash

set -e

# Created 2026-03-11 12:02:45

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08b.BHISTC_LTso.ne30_t232_wgx3.315"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08b/cime/scripts/create_newcase --compset BHISTC_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.315

./xmlchange RUN_REFDATE=0100-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/u/home/igrooms/runoff_mapping/map_r05_to_tx2_3_nnsm_e250r250_modified_260212.nc

./xmlchange ROF2OCN_LIQ_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100_250327.nc

