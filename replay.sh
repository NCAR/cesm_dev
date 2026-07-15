#!/bin/bash

set -e

# Created 2026-07-14 20:32:52

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09b.B1850C_MTso_Gris.ne30_t233_wgx3.366"

/glade/campaign/cesm/development/liwg/leguy/CESM3/code/cesm3_0_alpha09b/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6_MOSART_CISM2%GRIS-EVOLVE_WW3 --res ne30pg3_t233_wg37_gris4 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=bg.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.360a

./xmlchange RUN_REFDATE=0139-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange OCN_DIAG_MODE=spinup

./xmlchange RUN_REFCASE=bg.e30_alpha09b.B1850C_MTso.ne30_t233_wgx3.360a

./xmlchange RUN_REFDATE=0139-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange OCN_DIAG_MODE=spinup

./preview_namelists

./preview_namelists

./xmlchange PROJECT=CESM0023,RESUBMIT=15,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

