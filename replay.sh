#!/bin/bash

set -e

# Created 2026-03-25 11:46:16

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08m.B1850C_MTso.ne30_t232_wgx3.329_test3"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08m_cam_namelist_spinup2/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

