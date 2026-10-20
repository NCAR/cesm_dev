#!/bin/bash

set -e

# Created 2026-10-20 15:32:09

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha11b.B1850C_MTso.ne30_t233_wgx3.407"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha11b/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case b.e30_alpha11b.B1850C_MTso.ne30_t233_wgx3.407 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./pelayout

./case.setup

./xmlchange CAM_CONFIG_OPTS="-pcols 9" --append

