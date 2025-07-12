#!/bin/bash

set -e

# Created 2025-06-26 15:23:55

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.179"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_beta06/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.179 --run-unsupported --project CESM0023

cd "${CASEDIR}"

./case.setup

./xmlchange RUN_REFCASE=b.e30_alpha06e.B1850C_LTso.ne30_t232_wgx3.156

./xmlchange RUN_REFDATE=0077-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./case.build

./check_case

./case.submit

./xmlchange RESUBMIT=10,CONTINUE_RUN=False

./check_case

./case.submit

./xmlchange RESUBMIT=10

./case.submit

./xmlchange RESUBMIT=9

./case.submit

./xmlchange RESUBMIT=9

