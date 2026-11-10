#!/bin/bash

set -e

# Created 2026-11-10 09:39:41

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/f.e30_cam6_4_215.FHISTC_MTso.mapsa120.001"

/glade/work/hannay/cesm_tags/cam6_4_215/cime/scripts/create_newcase --compset FHISTC_MTso --res mpasa120_mpasa120_mt233 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS=5400

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_STARTDATE=1990-01-01

