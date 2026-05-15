#!/bin/bash

set -e

# Created 2026-05-15 07:50:19

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.346"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_alpha09a/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t233_wg37 --case b.e30_alpha09a.B1850C_MTso.ne30_t233_wgx3.346 --run-unsupported --project cesm0023

cd "${CASEDIR}"

./case.setup

