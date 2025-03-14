#!/bin/bash

set -e

# Created 2025-03-14 15:26:22

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.136"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha06b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.136 --run-unsupported --project CESM0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange RUN_REFCASE=b.e23_alpha17f.BLT1850.ne30_t232.130

./xmlchange RUN_REFDATE=0045-01-01

./case.build

./xmlchange RUN_REFCASE=b.e30_alpha06b.B1850C_LTso.ne30_t232_wgx3.130

./xmlchange RUN_REFDATE=0045-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

