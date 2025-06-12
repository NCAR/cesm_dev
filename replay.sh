#!/bin/bash

set -e

# Created 2025-05-15 15:02:17

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.170"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_beta06/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.170 --run-unsupported --project CESM0023

cd "${CASEDIR}"

./xmlchange RUN_REFCASE=b.e30_alpha06e.B1850C_LTso.ne30_t232_wgx3.156

./xmlchange RUN_REFDATE=0077-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./check_case

./case.submit

./xmlchange RESUBMIT=9

./case.submit

./case.submit

./xmlchange RESUBMIT=4

./case.submit

./xmlchange RESUBMIT=5

./case.submit

