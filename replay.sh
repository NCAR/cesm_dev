#!/bin/bash

set -e

# Created 2025-08-29 15:21:18

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.200"

/glade/work/hannay/cesm_tags/cesm3_0_beta06/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

