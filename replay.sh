#!/bin/bash

set -e

# Created 2025-02-26 06:29:49

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta05.BLT1850.ne30_t232_wgx3.129"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_beta05_v2/cime/scripts/create_newcase --compset 1850_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case b.e30_beta05.BLT1850.ne30_t232_wgx3.129 --run-unsupported --project CESM0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

