#!/bin/bash

set -e

# Created 2026-07-16 17:14:02

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09d_m.B1850C_MTso_Gris.ne30_t233_wgx3.369"

/glade/work/hannay/cesm_tags/cesm3_0_alpha09e_MARBL/cime/scripts/create_newcase --compset 1850C_CAM70%MT_CLM60%BGC-CROP_CICE_MOM6_MOSART_CISM2%GRIS-EVOLVE_WW3 --res ne30pg3_t233_wg37_gris4 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

