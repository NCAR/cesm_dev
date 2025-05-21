#!/bin/bash

set -e

# Created 2025-05-21 15:52:30

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.173"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_beta06/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.173 --run-unsupported --project CESM0023

cd "${CASEDIR}"

./case.setup

./xmlchange RUN_REFCASE=b.e30_alpha06e.B1850C_LTso.ne30_t232_wgx3.156

