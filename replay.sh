#!/bin/bash

set -e

# Created 2026-01-30 16:17:46

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.300"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.287

./xmlchange RUN_REFDATE=0125-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0023,RESUBMIT=4,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0023,RESUBMIT=4,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange CUPID_STARTDATE=0002-01-01

./xmlchange CUPID_STOP_N=64

./xmlchange CUPID_CLIMO_END_YEAR=1

./xmlchange CUPID_CLIMO_N_YEAR=20

./xmlchange CUPID_BASELINE_CASE=b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.299

./xmlchange CUPID_BASE_STARTDATE=0002-01-01

./xmlchange CUPID_BASE_STOP_N=20

./xmlchange CUPID_BASE_CLIMO_END_YEAR=1

./xmlchange CUPID_BASE_CLIMO_N_YEAR=20

./xmlchange CUPID_BASELINE_ROOT=/glade/derecho/scratch/hannay/archive

./xmlchange CUPID_EXAMPLE=key_metrics

./xmlchange CUPID_RUN_ALL=TRUE

./xmlchange CUPID_RUN_CVDP=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange CUPID_RUN_LDF=TRUE

./xmlchange CUPID_RUN_ALL=FALSE

./xmlchange CCUPID_RUN_ICE=TRUE

./xmlchange --subgroup case.cupid JOB_WALLCLOCK_TIME=4:00:00

./case.submit --only-job case.cupid

./xmlchange CUPID_STARTDATE=0002-01-01

./xmlchange CUPID_STOP_N=64

./xmlchange CUPID_CLIMO_END_YEAR=1

./xmlchange CUPID_CLIMO_N_YEAR=20

./xmlchange CUPID_BASELINE_CASE=b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.299

./xmlchange CUPID_BASE_STARTDATE=0002-01-01

./xmlchange CUPID_BASE_STOP_N=20

./xmlchange CUPID_BASE_CLIMO_N_YEAR=20

./xmlchange CUPID_RUN_CVDP=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange CUPID_RUN_LDF=TRUE

./xmlchange CUPID_RUN_ALL=FALSE

./xmlchange CCUPID_RUN_ICE=TRUE

