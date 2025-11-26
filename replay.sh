#!/bin/bash

set -e

# Created 2025-11-26 15:35:59

CASEDIR="/glade/work/cmip7/cases/testing/b.e30_alpha07f.B1850C_LTso.ne30_t232_wgx3.cmip7-testing.010"

/glade/work/cmip7/cesm_tags//cesm3_0_alpha07f/cime/scripts/create_newcase --case /glade/work/cmip7/cases/testing//b.e30_alpha07f.B1850C_LTso.ne30_t232_wgx3.cmip7-testing.010 --compset B1850C_LTso --workflow cmip7 --res ne30pg3_t232_wg37 --run-unsupported --project CESM0024

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_POSTPROCESSING=TRUE

./xmlchange JOB_PRIORITY=premium

./xmlchange RESUBMIT=5,STOP_N=2,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

