#!/bin/bash

set -e

# Created 2026-08-13 14:42:15

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.376.cupid"

/glade/work/hannay/cesm_tags/cesm3_0_alpha09e_MARBL/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./case.setup --reset

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.341

./xmlchange RUN_REFDATE=0239-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange OCN_DIAG_MODE=production

./preview_namelists

./xmlchange RUN_POSTPROCESSING=TRUE

./xmlchange CUPID_BASELINE_ROOT=/glade/campaign/cesm/development/cross-wg/diagnostic_framework/CESM_output_for_testing

./xmlchange CUPID_NICKNAME=376.cupid

./xmlchange CUPID_STOP_N=8

./xmlchange CUPID_BASELINE_CASE=b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.374

./xmlchange CUPID_BASE_NICKNAME=374

./xmlchange CUPID_BASE_STOP_N=116

./xmlchange CUPID_BASELINE_ROOT=/glade/derecho/scratch/hannay/archive

./xmlchange CUPID_REGRID_BASE_ATM_FILE=NONE

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=1,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=1,STOP_N=4,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

/glade/work/hannay/cesm_tags/cesm3_0_alpha09e_MARBL/tools/CUPiD/helper_scripts/generate_cupid_config_for_cesm_case.py --case-root "${CASEDIR}" --cesm-root /glade/work/hannay/cesm_tags/cesm3_0_alpha09e_MARBL --cupid-root /glade/work/hannay/cesm_tags/cesm3_0_alpha09e_MARBL/tools/CUPiD --cupid-example intermediary_outputs --cupid-baseline-case b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.374 --cupid-baseline-root /glade/derecho/scratch/hannay/archive --cupid-ts-dir /glade/derecho/scratch/hannay/archive/b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.376.cupid/.. --cupid-regrid FALSE --cupid-regrid-atm-file /glade/campaign/cesm/cesmdata/inputdata/cpl/gridmaps/ne30pg3/map_ne30pg3_TO_fv0.9x1.25_blin.240826.nc --cupid-regrid-base-atm-file NONE --cupid-startdate 0001-01-01 --cupid-enddate 0009-01-01 --cupid-base-startdate 0001-01-01 --cupid-base-enddate 0117-01-01 --cupid-climo-end-year 100 --cupid-climo-n-year 25 --cupid-base-climo-end-year 100 --cupid-base-climo-n-year 25 --case-nickname 376.cupid --base-nickname 374 --adf-output-root /glade/derecho/scratch/hannay/archive/b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.376.cupid/cupid --ldf-output-root /glade/derecho/scratch/hannay/archive/b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.376.cupid/cupid --ilamb-output-root /glade/derecho/scratch/hannay/archive/b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.376.cupid/cupid --cupid-run-adf FALSE --cupid-run-ldf FALSE --cupid-run-ilamb FALSE

