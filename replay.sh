#!/bin/bash

set -e

# Created 2026-02-18 11:44:44

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.284.mpas"

/glade/work/hannay/cesm_tags/cesm3_0_alpha07g_mpas/cime/scripts/create_newcase --compset B1850C_LTso --res mpasa120_t232 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./preview_namelists

./preview_namelists

./preview_namelists

./preview_namelists

./preview_namelists

./preview_namelists

./case.build

./preview_namelists

./case.build

./preview_namelists

./preview_namelists

./preview_namelists

./case.build

./case.submit

./case.submit

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

