#!/bin/bash

set -e

# Created 2026-01-23 15:11:18

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08a.B1850C_MTso.ne30_t232_wgx3.280.mcsp"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271

./xmlchange RUN_REFDATE=0109-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./case.build

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=30,STOP_N=1,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.setup

./case.setup --reset

./case.build --clean

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=30,STOP_N=1,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=20,STOP_N=1,STOP_OPTION=nyears

