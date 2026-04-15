#!/bin/bash

set -e

# Created 2026-04-15 09:57:21

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta08_dev_ncar.B1850C_MTso.ne30_t232_wgx3.337_out2"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_beta08_dev_ncar/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.330

