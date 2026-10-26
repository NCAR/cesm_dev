#!/bin/bash

set -e

# Created 2026-10-26 09:15:49

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/f.e30_cam6_4_215.FHISTC_MTso.ne30_control.001"

/glade/work/hannay/cesm_tags/cam6_4_215/cime/scripts/create_newcase --compset FHISTC_MTso --res ne30pg3_ne30pg3_mg17 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS=5400

./case.setup

./pelayout

./xmlchange NTASKS=5400

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_STARTDATE=1990-01-01

