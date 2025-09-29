#!/bin/bash

set -e

# Created 2025-09-29 16:13:18

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07c_cesm3_v2.B1850C_LTso.ne30_t232_wgx3.227"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07c_cesm3_v2/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha07c_cesm3_v2.B1850C_LTso.ne30_t232_wgx3.227 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange PROJECT=CESM0023,RESUBMIT=3,STOP_N=4,STOP_OPTION=nyears

./xmlchange JOB_PRIORITY=special --force

./case.build

./check_case

./case.submit

./case.submit

./check_case

./case.submit

