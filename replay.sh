#!/bin/bash

set -e

# Created 2026-10-21 09:13:50

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/f.e30_cam6_4_213.FHISTC_LTso.ne30_control.001"

/glade/work/hannay/cesm_tags/cam6_4_213/cime/scripts/create_newcase --compset FHISTC_LTso --res ne30pg3_ne30pg3_mg17 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS=5400

./case.setup

