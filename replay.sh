#!/bin/bash

set -e

# Created 2024-12-27 08:33:01

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_enthalpy_branch.BLT1850.ne30_t232_wgx3.113_method2cpdry"

/glade/work/gmarques/cesm.sandboxes/cesm3_0_enthalpy_branch/cime/scripts/create_newcase --compset 1850_CAM70%LT_CLM60%BGC-CROP_CICE_MOM6_MOSART_DGLC%NOEVOLVE_WW3_SESP --res ne30pg3_t232_wg37 --case b.e30_enthalpy_branch.BLT1850.ne30_t232_wgx3.113_method2cpdry --run-unsupported

cd "${CASEDIR}"

./xmlchange JOB_WALLCLOCK_TIME=01:00:00 --subgroup case.st_archive

./case.setup

./xmlchange RUN_REFCASE=b.e23_alpha17f.BLT1850.ne30_t232.098,RUN_REFDATE=0201-01-01,RUN_TYPE=hybrid,GET_REFCASE=true,RUN_REFDIR=cesm2_init,CHARGE_ACCOUNT=CESM0023,REST_OPTION=nyears,REST_N=1

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange --append CAM_CONFIG_OPTS="-rad rrtmgp"

./xmlchange STOP_OPTION=nyears,STOP_N=2

./xmlchange HIST_OPTION=nyears,HIST_N=1

./case.build

./check_case

./case.build

