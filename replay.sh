#!/bin/bash

set -e

# Created 2026-04-29 16:16:27

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/f.e30_cam6_4_163.FHISTC_LTso.ne30_t232_wgx3_raeder.001"

/glade/derecho/scratch/cacraig/cam6_4_163_raeder/cime/scripts/create_newcase --compset HIST_CAM70%LT_CLM60%SP_CICE%PRES_DOCN%DOM_MOSART_DGLC%NOEVOLVE_SWAV_SESP --res ne30pg3_ne30pg3_mg17 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS=3200

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_STARTDATE=1990-01-01

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

