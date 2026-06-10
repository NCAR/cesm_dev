#!/bin/bash

set -e

# Created 2026-06-10 14:35:16

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.354"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha09b/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t233_wg37 --case b.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.354 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./xmlchange CAM_CONFIG_OPTS="-pcols 9" --append

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.334

./xmlchange RUN_REFDATE=0100-01-01

./xmlchange RUN_TYPE=hybrid

