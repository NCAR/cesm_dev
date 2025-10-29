#!/bin/bash

set -e

# Created 2025-10-29 13:52:23

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07f_dev.B1850C_LTso.ne30_t232_wgx3.test-cupid.001"

/glade/work/hannay/cesm_tags/cesm3_0_alpha07f/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange RUN_POSTPROCESSING=TRUE.

./xmlchange RUN_POSTPROCESSING=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange RUN_POSTPROCESSING=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange RUN_POSTPROCESSING=TRUE

./xmlchange CUPID_BASELINE_CASE=b.e30_alpha07b_dev.B1850C_LTso.ne30_t232_wgx3.225

./xmlchange CUPID_BASELINE_ROOT=/glade/derecho/scratch/hannay/archive/

./xmlchange CUPID_BASE_NYEARS=20

./xmlchange CUPID_BASE_STARTDATE=0002-01-01

./xmlchange CUPID_EXAMPLE=key_metrics

./xmlchange CUPID_NYEARS=4

./xmlchange CUPID_STARTDATE=0002-01-01

./xmlchange CUPID_TS_DIR=/glade/derecho/scratch/hannay/archive/

