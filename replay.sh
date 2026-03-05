#!/bin/bash

set -e

# Created 2026-03-04 22:04:41

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/f.e30_alpha08b.FHISTC_MTso.ne30_t232_wgx3.316_pi"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08b/cime/scripts/create_newcase --compset HIST_CAM70%MT_CLM60%SP_CICE%PRES_DOCN%DOM_MOSART_DGLC%NOEVOLVE_SWAV_SESP --res ne30pg3_ne30pg3_mg17 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS=3200

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.287

./xmlchange RUN_REFDATE=0125-01-01

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange RUN_STARTDATE=1990-01-01

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=3,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./preview_namelists

./xmlchange JOB_PRIORITY=regular

