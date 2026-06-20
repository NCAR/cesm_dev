#!/bin/bash

set -e

# Created 2026-06-18 15:31:54

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09b.BHISTC_MTso.ne30_t233_wgx3.357"

/glade/work/hannay/cesm_tags/cesm3_0_alpha09b/cime/scripts/create_newcase --compset BHISTC_MTso --res ne30pg3_t233_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.357

./xmlchange RUN_REFDATE=0013-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange OCN_DIAG_MODE=spinup

./xmlchange OCN_DIAG_MODE=spinup

./preview_namelists

./preview_namelists

./case.build

./case.build

./case.build

./xmlchange OCN_DIAG_MODE=spinup

