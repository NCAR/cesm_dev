#!/bin/bash

set -e

# Created 2025-11-21 08:16:17

CASEDIR="/glade/work/cmip7/cases/testing/b.e30_alpha07f.B1850C_LTso.ne30_t232_wgx3.cmip7-testing.008"

/glade/work/cmip7/cesm_tags//cesm3_0_alpha07f/cime/scripts/create_newcase --case /glade/work/cmip7/cases/testing//b.e30_alpha07f.B1850C_LTso.ne30_t232_wgx3.cmip7-testing.008 --compset B1850C_LTso --workflow cmip7 --res ne30pg3_t232_wg37 --run-unsupported --project CESM0024

cd "${CASEDIR}"

./case.setup

