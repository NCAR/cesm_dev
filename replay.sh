#!/bin/bash

set -e

# Created 2026-08-19 08:27:51

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09e_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.386"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha09e_MARBL/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6%MARBL-BIO_MOSART_CISM2%GRIS-EVOLVE_WW3_SESP --res ne30pg3_t233_wg37_gris4 --case b.e30_alpha09e_m.B1850C_MTso_Gris_Marbl.ne30_t233_wgx3.386 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

