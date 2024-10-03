#!/bin/bash

set -e

# Created 2024-10-03 15:18:48

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha03d.BLT1850.ne30_t232_wgx3.112"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha03d_cice/cime/scripts/create_newcase --compset 1850_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case b.e30_alpha03d.BLT1850.ne30_t232_wgx3.112 --run-unsupported

cd "${CASEDIR}"

./case.setup

./pelayout

./xmlchange JOB_WALLCLOCK_TIME=01:00:00 --subgroup case.st_archive

