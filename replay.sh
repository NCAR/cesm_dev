#!/bin/bash

set -e

# Created 2026-07-17 14:17:44

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.370"

/glade/work/hannay/cesm_tags/cesm3_0_alpha09e_MARBL/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS_OCN=2560

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha09b.B1850C_MTso_Gris.ne30_t233_wgx3.366

./xmlchange RUN_REFDATE=0021-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange OCN_DIAG_MODE=spinup

./preview_namelists

./case.build

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=0,STOP_N=1,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./preview_namelists

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=0,STOP_N=1,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange NTASKS_OCN=2560

./xmlchange NTASKS_OCN=2816

./case.setup --reset

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=0,STOP_N=1,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./xmlchange NTASKS_OCN=2560

./case.setup

./case.setup --reset

./case.setup --reset

./case.build

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=15,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=15,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

