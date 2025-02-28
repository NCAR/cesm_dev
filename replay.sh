#!/bin/bash

set -e

# Created 2024-11-25 11:28:24

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta04.BLT1850.ne30_t232_wgx3.118"

/glade/work/hannay/cesm_tags/cesm3_0_beta04/cime/scripts/create_newcase --compset 1850_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange --append CAM_CONFIG_OPTS="-rad rrtmgp"

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e23_alpha17f.BLT1850.ne30_t232.098

./xmlchange RUN_REFDATE=0201-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange MOM6_VERTICAL_GRID=hycom1

./preview_namelists

./case.build

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=2,STOP_OPTION=nyears

./xmlchange CHARGE_ACCOUNT=CESM0023

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.submit

./xmlchange RESUBMIT=10

