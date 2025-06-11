#!/bin/bash

set -e

# Created 2025-06-11 13:40:04

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha06e.B1850C_LTso.ne30_t232_wgx3.budget.156b"

/glade/work/hannay/cesm_tags/cesm3_0_alpha06e/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_alpha06e.B1850C_LTso.ne30_t232_wgx3.156

./xmlchange RUN_REFDATE=0157-01-01

./xmlchange RUN_TYPE=branch

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_alpha06e.B1850C_LTso.ne30_t232_wgx3.156

./xmlchange RUN_REFDATE=0157-01-01

./xmlchange RUN_TYPE=branch

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

