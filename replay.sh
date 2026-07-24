#!/bin/bash

set -e

# Created 2026-07-24 15:17:21

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.372"

/glade/work/hannay/cesm_tags/cesm3_0_alpha09e_MARBL/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS_OCN=2560

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha09d_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.370

./xmlchange RUN_REFDATE=0053-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=special --force

