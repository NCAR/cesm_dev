#!/bin/bash

set -e

# Created 2025-11-26 11:40:07

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07c_cesm.B1850C_LTso.ne30_t232_wgx3.256"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07c_cesm3/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./case.setup --reset

./case.build --clean-all

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

