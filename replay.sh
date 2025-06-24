#!/bin/bash

set -e

# Created 2025-06-24 15:02:35

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_beta06.BHISTC_LTso.ne30_t232_wgx3.166"

/glade/work/hannay/cesm_tags/cesm3_0_beta06/cime/scripts/create_newcase --compset HISTC_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange RUN_REFDATE=0237-01-01

./case.setup

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_beta06.B1850C_LTso.ne30_t232_wgx3.166

./xmlchange RUN_REFDATE=0237-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./case.build

