#!/bin/bash

set -e

# Created 2025-04-11 10:03:12

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.153"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha06b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.153 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

