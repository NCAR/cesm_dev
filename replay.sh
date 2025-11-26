#!/bin/bash

set -e

# Created 2025-11-26 11:40:07

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07c_cesm.B1850C_LTso.ne30_t232_wgx3.256"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07c_cesm3/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

