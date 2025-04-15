#!/bin/bash

set -e

# Created 2025-04-04 14:33:56

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.150"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha06b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.150 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.130

./xmlchange RUN_REFDATE=0045-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./check_case

./case.submit

./check_case

./case.submit

./xmlchange RESUBMIT=9

./case.submit

./case.submit

./case.submit

./xmlchange DRV_RESTART_POINTER=rpointer.cpl.0073-01-01-00000

./case.submit

./xmlchange RESUBMIT=4

