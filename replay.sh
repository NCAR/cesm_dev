#!/bin/bash

set -e

# Created 2026-09-04 10:37:19

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/f.e30_gll_double_adv.FHISTC_MTso.ne30_nirvana.001"

/glade/work/hannay/cesm_tags/gll_double_adv/cime/scripts/create_newcase --compset HIST_CAM70%MT_CLM60%SP_CICE%PRES_DOCN%DOM_MOSART_DGLC%NOEVOLVE_SWAV_SESP --res ne30pg3_ne30pg3_mg17 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS=3200

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange RUN_STARTDATE=1980-01-01

./preview_namelists

./preview_namelists

./case.build

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=9,STOP_N=2,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./preview_namelists

./preview_namelists

./case.build

./xmlchange NTASKS=5400

./case.setup --reset

./case.build --clean

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange RUN_STARTDATE=1980-01-01

./preview_namelists

./preview_namelists

./case.build

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange RUN_STARTDATE=1980-01-01

./preview_namelists

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange RUN_STARTDATE=1980-01-01

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

