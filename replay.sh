#!/bin/bash

set -e

# Created 2025-03-06 13:14:15

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.132"

/glade/work/hannay/cesm_tags/cesm3_0_alpha06b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_beta05.BLT1850.ne30_t232_wgx3.129

./xmlchange RUN_REFDATE=0049-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./case.build

./preview_namelists

./case.build

./xmlchange RUN_REFCASE=b.e30_beta04.BLT1850.ne30_t232_wgx3.127

./xmlchange RUN_REFDATE=0049-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_beta05.BLT1850.ne30_t232_wgx3.127

./xmlchange RUN_REFDATE=0049-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./case.build

./preview_namelists

./case.build

./case.build

./case.build --clean

./case.build

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange JOB_PRIORITY=regular

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange RUN_REFCASE=b.e30_beta05.BLT1850.ne30_t232_wgx3.127

./xmlchange RUN_REFDATE=0049-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./case.submit

./preview_namelists

./case.submit

./case.submit

