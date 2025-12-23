#!/bin/bash

set -e

# Created 2025-12-23 14:43:00

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha07g.BHISTC_LTso.ne30_t232_wgx3.271sturm"

/glade/work/hannay/cesm_tags/cesm3_0_alpha07g/cime/scripts/create_newcase --compset BHISTC_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271

./xmlchange RUN_REFDATE=0061-01-01

