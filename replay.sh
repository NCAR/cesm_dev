#!/bin/bash

set -e

# Created 2025-12-26 22:22:25

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.275.wav"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07g_ww3_diags/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.275.wav --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.275

./xmlchange RUN_REFDATE=0037-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./case.build

./check_case

./xmlchange STOP_OPTION=nyears,STOP_N=4

./xmlchange JOB_PRIORITY=premium

./xmlchange RESUBMIT=9

./case.submit

./case.submit

