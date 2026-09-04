#!/bin/bash

set -e

# Created 2026-09-03 16:55:11

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/f.e30_gll_double_adv.FHISTC_MTso.ne30_control.001"

/glade/work/hannay/cesm_tags/gll_double_adv/cime/scripts/create_newcase --compset HIST_CAM70%MT_CLM60%SP_CICE%PRES_DOCN%DOM_MOSART_DGLC%NOEVOLVE_SWAV_SESP --res ne30pg3_ne30pg3_mg17 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./xmlchange NTASKS=3200

./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_TYPE=startup

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange RUN_STARTDATE=1980-01-01

./preview_namelists

./preview_namelists

./case.build

./preview_namelists

./preview_namelists

./case.build

