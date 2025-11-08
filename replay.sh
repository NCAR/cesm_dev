#!/bin/bash

set -e

# Created 2025-11-07 20:17:41

CASEDIR="/glade/u/home/cmip7/cases/testing/b.e30_alpha07f.B1850C_LTso.ne30_t232_wgx3.cmip7-testing.002"

/glade/work/cmip7/cesm_tags/cesm3_0_alpha07f/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project CESM0024 --workflow cmip7

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange JOB_PRIORITY=premium

./xmlchange JOB_PRIORITY=special --force

