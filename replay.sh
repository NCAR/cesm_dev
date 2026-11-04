#!/bin/bash

set -e

# Created 2026-11-04 09:39:55

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha11d.B1850_MTso.ne30_t233_wgx3.421"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha11d/cime/scripts/create_newcase --compset 1850_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case b.e30_alpha11d.B1850_MTso.ne30_t233_wgx3.421 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CAM_CONFIG_OPTS="-pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

