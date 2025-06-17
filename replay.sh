#!/bin/bash

set -e

# Created 2025-01-07 16:44:48

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta04.BLTHIST.ne30_t232_wgx3.121"

/glade/work/hannay/cesm_tags/cesm3_0_beta04/cime/scripts/create_newcase --compset HIST_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange --append CAM_CONFIG_OPTS="-rad rrtmgp"

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_beta04.BLT1850.ne30_t232_wgx3.121

./xmlchange RUN_REFDATE=0075-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./preview_namelists

./case.build

./preview_namelists

./preview_namelists

./preview_namelists

./case.build

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=2,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange RESUBMIT=50

./xmlchange RESUBMIT=30

./case.submit

./case.setup --reset

./case.setup --reset

./case.build --clean

./case.build

./case.submit

./case.submit

./case.setup --reset

./case.build --clean

./preview_namelists

./case.build

./xmlchange PROJECT=CESM0023,RESUBMIT=75,STOP_N=2,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.submit

./xmlchange STOP_N=1

./case.submit

