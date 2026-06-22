#!/bin/bash

set -e

# Created 2026-06-22 14:41:34

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.359"

/glade/work/hannay/cesm_tags/cesm3_0_alpha09b/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t233_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.350

./xmlchange RUN_REFDATE=0077-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange OCN_DIAG_MODE=spinup

./preview_namelists

./preview_namelists

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.348

./xmlchange RUN_REFDATE=0213-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange OCN_DIAG_MODE=spinup

./preview_namelists

./preview_namelists

./preview_namelists

./case.build

./case.build

./case.build

./xmlchange JOB_PRIORITY=special --force

