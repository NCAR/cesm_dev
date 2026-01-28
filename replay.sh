#!/bin/bash

set -e

# Created 2026-01-13 19:53:09

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.287"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07g_ww3_diags/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.287 --run-unsupported --project cesm0030

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha07c_cesm.B1850C_LTso.ne30_t232_wgx3.247

./xmlchange RUN_REFDATE=0097-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange JOB_PRIORITY=special --force

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./case.build

./check_case

./case.submit

./xmlchange RESUBMIT=9

./xmlchange JOB_PRIORITY=premium

./case.submit

./xmlchange RESUBMIT=9

./case.submit

./xmlchange RESUBMIT=19

./case.submit

./xmlchange JOB_PRIORITY=special --force

./case.submit

./xmlchange PROJECT=CESM0002

