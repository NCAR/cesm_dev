#!/bin/bash

set -e

# Created 2025-11-10 11:52:42

CASEDIR="/glade/u/home/cmip7/cases/testing/b.e30_alpha07f.B1850C_LTso.ne30_t232_wgx3.cmip7-testing.003"

/glade/work/cmip7/cesm_tags/cesm3_0_alpha07f/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project CESM0024 --workflow cmip7

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./preview_namelists

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0024,RESUBMIT=2,STOP_N=3,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0024,RESUBMIT=2,STOP_N=3,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./case.build

./case.submit

./xmlchange PROJECT=CESM0024,RESUBMIT=0,STOP_N=3,STOP_OPTION=ndays

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./case.submit

./xmlchange PROJECT=CESM0024,RESUBMIT=2,STOP_N=3,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./case.submit

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.submit

./case.submit

./case.submit

./case.setup --reset

./case.setup --reset

./case.build

./case.submit

./case.submit

./case.submit

./case.submit

