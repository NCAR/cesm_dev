#!/bin/bash

set -e

# Created 2026-06-17 14:11:55

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.357"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha09b/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t233_wg37 --case b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.357 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CAM_CONFIG_OPTS="-pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange RUN_REFCASE=b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.348

./xmlchange RUN_REFDATE=0213-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange PROJECT=CESM0023,RESUBMIT=15,STOP_N=6,STOP_OPTION=nyears

./case.setup --reset

./case.build --clean

./case.build

./case.build

./check_case

./xmlchange JOB_PRIORITY=special --force

./case.submit

./check_case

./preview_namelists

./case.submit

./pelayout

