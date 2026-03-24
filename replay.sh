#!/bin/bash

set -e

# Created 2026-03-24 14:39:30

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08m.B1850C_LTso.ne30_t232_wgx3.329_test2"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08m/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_TYPE=startup

