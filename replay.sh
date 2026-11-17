#!/bin/bash

set -e

# Created 2026-11-17 15:59:40

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha11d_landice.B1850_MTso.ne30_t233_wgx3.434"

/glade/work/hannay/cesm_tags/cesm3_0_alpha11d_landice/cime/scripts/create_newcase --compset 1850_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./case.setup --reset

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.334

./xmlchange RUN_REFDATE=0101-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange OCN_DIAG_MODE=production

./preview_namelists

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=25,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./xmlchange OCN_DIAG_MODE=production

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/r05_1000km/map_r05_to_tx2_3_nnsm_e1000r1000sh_e250r250nh_merged_modified_261117.nc

./case.build

./xmlchange PROJECT=CESM0023

