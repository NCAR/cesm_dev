#!/bin/bash

set -e

# Created 2026-05-15 07:50:19

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.346"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha09a/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t233_wg37 --case b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.346 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CAM_CONFIG_OPTS="-pcols 9 --append"

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.341

./xmlchange RUN_REFDATE=0107-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./case.build

./xmlchange CAM_CONFIG_OPTS="-pcols 9 -phys cam7 -model_top mt  -pcols 9"

./case.build

./case.build

./case.build --clean atm

./case.build

./check_case

./xmlchange OCN_DIAG_MODE=spinup

./case.submit

./pelayout

./case.setup --reset

./case.build

./pelayout

./check_case

./case.submit

./pelayout

./pelayout

./pelayout

./xmlchange RESUBMIT=9

./case.submit

./pelayout

./xmlchange RESUBMIT=3

