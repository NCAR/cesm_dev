#!/bin/bash

set -e

# Created 2025-11-10 14:37:26

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07c_cesm.B1850C_LTso.ne30_t232_wgx3.247"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07c_cesm3/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS_ICE=1920

./xmlchange ROOTPE_ICE=0

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./case.build

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange RESUBMIT=0

./xmlchange NTASKS_ATM=2700,NTASKS_LND=2700,NTASKS_ICE=2700,NTASKS_ROF=1280,NTASKS_GLC=116,NTASKS_WAV=116,NTASKS_CPL=2700,ROOTPE_OCN=2816,ROOTPE_GLC=2700,ROOTPE_WAV=2700

./xmlchange NTASKS_ATM=2700,NTASKS_LND=2700,NTASKS_ICE=2700,NTASKS_ROF=1280,NTASKS_GLC=116,NTASKS_WAV=116,NTASKS_CPL=2700,ROOTPE_OCN=2816,ROOTPE_GLC=2700,ROOTPE_WAV=2700

./case.setup --reset

./case.build --clean-all

./case.build

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

