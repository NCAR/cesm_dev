#!/bin/bash

set -e

# Created 2026-08-14 09:51:50

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09e_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.381"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha09e_MARBL/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case b.e30_alpha09e_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.381 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CAM_CONFIG_OPTS="-pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.341

./xmlchange RUN_REFDATE=0239-01-01

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.341

./xmlchange RUN_REFDATE=0239-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./case.build

./pelayout

./case.setup

./case.setup --reset

./case.build

./pelayout

./xmlchange STOP_N=4,STOP_OPTION=nyears,RESUBMIT=30

./xmlchange JOB_PRIORITY=special --force

./check_case

./case.submit

./check_case

./case.submit

./check_case

./case.submit

./case.submit

./case.submit

