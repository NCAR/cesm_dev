#!/bin/bash

set -e

# Created 2025-03-06 20:59:17

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta05.BLT1850.ne30_t232_wgx3.127"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_beta05/cime/scripts/create_newcase --compset 1850_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case b.e30_beta05.BLT1850.ne30_t232_wgx3.127 --run-unsupported --project CESM0023

cd "${CASEDIR}"

./case.setup

./case.setup --reset

./case.build

./xmlchange CONTINUE_RUN=True

./xmlchange RESUBMIT=4

./check_case

./xmlchange STOP_OPTION=nyears,STOP_N=4

./case.submit

./case.submit

./case.submit

./xmlchange STOP_N=2

./xmlchange RESUBMIT=8

./case.submit

./case.submit

./xmlchange JOB_WALLCLOCK_TIME=01:30 --subgroup case.st_archive

./xmlchange STOP_N=3

./case.submit

./xmlchange JOB_WALLCLOCK_TIME=01:30:00 --subgroup case.st_archive

./case.submit --job case.st_archive

