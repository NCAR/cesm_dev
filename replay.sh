#!/bin/bash

set -e

# Created 2025-08-22 14:43:31

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta06.BHISTC_LTso.ne30_t232_wgx3.192"

/glade/work/hannay/cesm_tags/cesm3_0_beta06/cime/scripts/create_newcase --compset HISTC_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

