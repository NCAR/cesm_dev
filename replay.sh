#!/bin/bash

set -e

# Created 2025-09-05 16:33:32

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta06.BHISTC_LTso.ne30_t232_wgx3_fixed_emission.200"

/glade/work/hannay/cesm_tags/cesm3_0_beta06/cime/scripts/create_newcase --compset HISTC_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.200

./xmlchange RUN_REFDATE=0045-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange CAM_NML_USE_CASE=hist_cam_lt

./preview_namelists

./case.build

./xmlchange PROJECT=CESM0023,RESUBMIT=20,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./xmlchange JOB_PRIORITY=special --force

./case.submit

