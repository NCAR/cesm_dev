#!/bin/bash

set -e

# Created 2026-01-05 17:22:47

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.284"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07g_ww3_diags/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.284 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./check_case

./case.submit

./case.submit

