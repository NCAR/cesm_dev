#!/bin/bash

set -e

# Created 2025-02-14 15:09:39

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta05.BLT1850.ne30_t232_wgx3.125"

/glade/work/hannay/cesm_tags/cesm3_0_beta05/cime/scripts/create_newcase --compset 1850_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e23_alpha17f.BLT1850.ne30_t232.098

./xmlchange RUN_REFDATE=0201-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./case.build

./preview_namelists

./case.build

./preview_namelists

./preview_namelists

./preview_namelists

./case.build

./preview_namelists

./case.build

./preview_namelists

./preview_namelists

./preview_namelists

./preview_namelists

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0023,RESUBMIT=0,STOP_N=5,STOP_OPTION=ndays

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0023,RESUBMIT=0,STOP_N=5,STOP_OPTION=ndays

./xmlchange JOB_WALLCLOCK_TIME=2:00:00 --subgroup case.run

./case.submit

./case.submit

./case.submit

./case.submit

./preview_namelists

./case.build

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.setup --reset

./case.build --clean

./preview_namelists

./case.build

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0023,RESUBMIT=0,STOP_N=5,STOP_OPTION=ndays

./xmlchange JOB_WALLCLOCK_TIME=2:00:00 --subgroup case.run

./case.submit

./xmlchange CONTINUE_RUN=FALSE

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0023,RESUBMIT=0,STOP_N=5,STOP_OPTION=ndays

./xmlchange JOB_WALLCLOCK_TIME=2:00:00 --subgroup case.run

./case.submit

./case.submit

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange CONTINUE_RUN=FALSE

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.submit

./xmlchange RESUBMIT=4

./case.submit

