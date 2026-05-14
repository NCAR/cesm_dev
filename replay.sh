#!/bin/bash

set -e

# Created 2026-05-14 00:36:31

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.345"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08o/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.338

./xmlchange RUN_REFDATE=0031-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

