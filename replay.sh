#!/bin/bash

set -e

# Created 2025-08-29 16:29:54

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07b.B1850C_LTso.ne30_t232_wgx3.201"

/glade/work/hannay/cesm_tags/cesm3_0_alpha07b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

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

