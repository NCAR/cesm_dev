#!/bin/bash

set -e

# Created 2025-08-20 08:30:37

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07b_dev.B1850C_LTso.ne30_t232_wgx3.196"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07b_dev/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha07b_dev.B1850C_LTso.ne30_t232_wgx3.196 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange REST_OPTION=nyears,REST_N=1

