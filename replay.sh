#!/bin/bash

set -e

# Created 2026-05-28 15:09:50

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.350"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha09b/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t233_wg37 --case b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.350 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CAM_CONFIG_OPTS="-pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.341

./xmlchange RUN_REFDATE=0107-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange RUN_REFDATE=0199-01-01

./case.build

./case.build --clean atm

./case.build

./xmlchange OCN_DIAG_MODE=spinup

./check_case

./xmlchange PROJECT=CESM0023,RESUBMIT=15,STOP_N=4,STOP_OPTION=nyears

./xmlchange JOB_PRIORITY=special --force

./case.submit

./pelayout

./pelayout

./xmlchange RESUBMIT=19

./case.submit

./xmlchange RESUBMIT=9

./case.submit

./pelayout

./pelayout

./pelayout

./xmlchange RESUBMIT=6

./xmlchange JOB_PRIORITY=regular

