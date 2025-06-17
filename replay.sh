#!/bin/bash

set -e

# Created 2025-03-12 14:00:39

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.134"

/glade/work/hannay/cesm_tags/cesm3_0_alpha06b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.130

./xmlchange RUN_REFDATE=0045-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.submit

./case.submit

./case.submit

./xmlchange RESUBMIT=0

