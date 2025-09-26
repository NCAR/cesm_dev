#!/bin/bash

set -e

# Created 2025-09-26 15:44:55

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07b_dev.B1850C_LTso.ne30_t232_wgx3.223"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07b_dev/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

