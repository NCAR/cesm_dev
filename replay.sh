#!/bin/bash

set -e

# Created 2025-12-26 22:22:25

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.275.wav"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha07g_ww3_diags/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.275.wav --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

