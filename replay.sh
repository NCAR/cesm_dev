#!/bin/bash

set -e

# Created 2026-05-23 04:44:19

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.349"

/glade/work/hannay/cesm_tags/cesm3_0_alpha09b/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t233_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.347

./xmlchange RUN_REFDATE=0113-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./case.build

./xmlchange RUN_REFCASE=b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.347

./xmlchange RUN_REFDATE=0113-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./case.build

./preview_namelists

./xmlchange OCN_DIAG_MODE=spinup

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=15,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange RUN_REFCASE=b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.347

./xmlchange RUN_REFDATE=0113-01-01

