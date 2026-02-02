#!/bin/bash

set -e

# Created 2026-02-02 14:50:25

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.303"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.287

./xmlchange RUN_REFDATE=0125-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./case.build

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

