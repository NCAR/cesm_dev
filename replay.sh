#!/bin/bash

set -e

# Created 2026-03-20 15:46:26

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.328"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha08b/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case b.e30_alpha08b.B1850C_LTso.ne30_t232_wgx3.328 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange MASK_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.n

./xmlchange OCN_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

