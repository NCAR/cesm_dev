#!/bin/bash

set -e

# Created 2026-10-27 17:17:30

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha11d.B1850_MTso.ne30_t233_wgx3.419"

/glade/work/hannay/cesm_tags/cesm3_0_alpha11d/cime/scripts/create_newcase --compset 1850_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./case.setup --reset

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha11b.B1850C_MTso.ne30_t233_wgx3.416

./xmlchange RUN_REFDATE=0021-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

