#!/bin/bash

set -e

# Created 2026-03-31 15:21:30

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/f.e30_alpha08o.FHISTC_LTso.ne30_t232_wgx3_baseline.001"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08o/cime/scripts/create_newcase --compset HIST_CAM70%LT_CLM60%SP_CICE%PRES_DOCN%DOM_MOSART_DGLC%NOEVOLVE_SWAV_SESP --res ne30pg3_ne30pg3_mg17 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS=3200

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_STARTDATE=1980-01-01

./preview_namelists

./preview_namelists

./case.build

./preview_namelists

./case.build

./preview_namelists

./case.build

./preview_namelists

./preview_namelists

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=premium

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=3,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange JOB_PRIORITY=special --force

./xmlchange RUN_STARTDATE=1990-01-01

./xmlchange PROJECT=CESM0023,RESUBMIT=2,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange REST_OPTION=nyears,REST_N=1

