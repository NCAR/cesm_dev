#!/bin/bash

set -e

# Created 2025-09-17 14:19:25

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07c_cesm.B1850C_LTso.ne30_t232_wgx3.216"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07c_cesm3/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha07c_cesm.B1850C_LTso.ne30_t232_wgx3.216 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange PROJECT=CESM0023,RESUBMIT=12,STOP_N=4,STOP_OPTION=nyears

./case.build

./xmlchange JOB_PRIORITY=special --force

./check_case

./preview_namelists

./check_case

./case.submit

