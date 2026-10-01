#!/bin/bash

set -e

# Created 2026-10-01 15:34:45

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha10c.B1850C_MTso.ne30_t233_wgx3.404"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha10c/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case b.e30_alpha10c.B1850C_MTso.ne30_t233_wgx3.404 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CAM_CONFIG_OPTS="-pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha09e_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.397

./xmlchange RUN_REFDATE=0094-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange CAM_NML_USE_CASE=1850_cam_mt

