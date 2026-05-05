#!/bin/bash

set -e

# Created 2026-04-30 14:46:28

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.342"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08o/cime/scripts/create_newcase --compset B1850C_MTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CAM_CONFIG_OPTS=" -pcols 9" --append

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.338

./xmlchange RUN_REFDATE=0031-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/u/home/igrooms/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100sh_e250r250nh_merged_modified_260317.nc

./xmlchange ROF2OCN_LIQ_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100_260306.nc

./xmlchange ICE_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange OCN_DOMAIN_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./xmlchange MASK_MESH=/glade/work/gmarques/cesm/tx2_3/mesh/ESMF_mesh_tx2_3v3_260305_cdf5.nc

./preview_namelists

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=20,STOP_N=2,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.build

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=20,STOP_N=2,STOP_OPTION=nyears

./xmlchange PROJECT=CESM0023

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./case.submit

./xmlchange RESUBMIT=10

./xmlchange CUPID_STARTDATE=0002-01-01

./xmlchange CUPID_STOP_N=40

./xmlchange CUPID_BASE_STARTDATE=0002-01-01

./xmlchange CUPID_BASE_STOP_N=40

./xmlchange CUPID_CLIMO_END_YEAR=41

./xmlchange CUPID_CLIMO_N_YEAR=40

./xmlchange CUPID_BASE_CLIMO_END_YEAR=41

./xmlchange CUPID_BASE_CLIMO_N_YEAR=40

./xmlchange CUPID_BASELINE_CASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.338

./xmlchange CUPID_BASELINE_ROOT=/glade/derecho/scratch/hannay/archive

./xmlchange CUPID_EXAMPLE=key_metrics

./xmlchange CUPID_RUN_ALL=TRUE

./xmlchange CUPID_RUN_CVDP=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange CUPID_RUN_LDF=TRUE

./xmlchange --subgroup case.cupid JOB_WALLCLOCK_TIME=12:00:00

./case.submit --only-job case.cupid

./xmlchange --subgroup case.cupid JOB_WALLCLOCK_TIME=6:00:00

./case.submit --only-job case.cupid

/glade/work/hannay/cesm_tags/cesm3_0_alpha08o/tools/CUPiD/helper_scripts/generate_cupid_config_for_cesm_case.py --run-cvdp --case-root "${CASEDIR}" --cesm-root /glade/work/hannay/cesm_tags/cesm3_0_alpha08o --cupid-root /glade/work/hannay/cesm_tags/cesm3_0_alpha08o/tools/CUPiD --cupid-example key_metrics --cupid-baseline-case b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.338 --cupid-baseline-root /glade/derecho/scratch/hannay/archive --cupid-ts-dir /glade/derecho/scratch/hannay/archive/b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.342/.. --cupid-startdate 0002-01-01 --cupid-enddate 0042-01-01 --cupid-base-startdate 0002-01-01 --cupid-base-enddate 0042-01-01 --cupid-climo-end-year 41 --cupid-climo-n-year 40 --cupid-base-climo-end-year 41 --cupid-base-climo-n-year 40 --adf-output-root "${CASEDIR}"/cupid-postprocessing --ldf-output-root "${CASEDIR}"/cupid-postprocessing --ilamb-output-root "${CASEDIR}"/cupid-postprocessing --cupid-run-adf TRUE --cupid-run-ldf TRUE --cupid-run-ilamb FALSE

./case.submit

./case.submit

./xmlchange CUPID_STARTDATE=0002-01-01

./xmlchange CUPID_STOP_N=40

./xmlchange CUPID_BASE_STARTDATE=0002-01-01

./xmlchange CUPID_BASE_STOP_N=40

./xmlchange CUPID_CLIMO_END_YEAR=41

./xmlchange CUPID_CLIMO_N_YEAR=40

./xmlchange CUPID_BASE_CLIMO_END_YEAR=41

./xmlchange CUPID_BASE_CLIMO_N_YEAR=40

./xmlchange CUPID_BASELINE_CASE=b.e30_alpha08o.B1850C_MTso.ne30_t232_wgx3.338

./xmlchange CUPID_BASELINE_ROOT=/glade/derecho/scratch/hannay/archive

./xmlchange CUPID_EXAMPLE=key_metrics

./xmlchange CUPID_RUN_ALL=TRUE

./xmlchange CUPID_RUN_CVDP=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange CUPID_RUN_LDF=TRUE

./xmlchange --subgroup case.cupid JOB_WALLCLOCK_TIME=6:00:00

