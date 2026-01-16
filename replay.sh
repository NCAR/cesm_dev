#!/bin/bash

set -e

# Created 2025-12-30 19:39:02

CASEDIR="/glade/campaign/cesm/cesmdata/cseg/runs/cesm2_0/b.e30_alpha08a.B1850C_LTso.ne30_t232_wgx3.280"

/glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142/cime/scripts/create_newcase --compset B1850C_LTso --res ne30pg3_t232_wg37 --case "${CASEDIR}" --run-unsupported --project 93300722

cd "${CASEDIR}"

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RUN_REFCASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271

./xmlchange RUN_REFDATE=0109-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./preview_namelists

./xmlchange RUN_REFCASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271

./xmlchange RUN_REFDATE=0109-01-01

./xmlchange RUN_TYPE=hybrid

./xmlchange GET_REFCASE=true

./xmlchange RUN_REFDIR=cesm2_init

./case.setup

./preview_namelists

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./preview_namelists

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange JOB_PRIORITY=special --force

./xmlchange PROJECT=CESM0023,RESUBMIT=10,STOP_N=4,STOP_OPTION=nyears

./xmlchange REST_OPTION=nyears,REST_N=1

./xmlchange JOB_WALLCLOCK_TIME=12:00:00 --subgroup case.run

./case.submit

./preview_namelists

./case.build

./case.build

./case.build

./case.submit

./case.build

./case.submit

./case.submit

./xmlchange RESUBMIT=10

./xmlchange CUPID_STARTDATE=0002-01-01

./xmlchange CUPID_STOP_N=20

./xmlchange CUPID_BASE_STARTDATE=0002-01-01

./xmlchange CUPID_BASE_STOP_N=20

./xmlchange CUPID_BASELINE_CASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271

./xmlchange CUPID_BASELINE_ROOT=/glade/derecho/scratch/hannay/archive

./xmlchange CUPID_EXAMPLE=key_metrics

./xmlchange CUPID_RUN_ALL=TRUE

./xmlchange CUPID_RUN_CVDP=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./case.submit --only-job case.cupid

./case.submit --only-job case.cupid

/glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142/tools/CUPiD/helper_scripts/generate_cupid_config_for_cesm_case.py --run-cvdp --case-root "${CASEDIR}" --cesm-root /glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142 --cupid-root /glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142/tools/CUPiD --cupid-example key_metrics --cupid-baseline-case b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271 --cupid-baseline-root /glade/derecho/scratch/hannay/archive --cupid-ts-dir /glade/derecho/scratch/hannay/archive/b.e30_alpha08a.B1850C_LTso.ne30_t232_wgx3.280/.. --cupid-startdate 0002-01-01 --cupid-enddate 0022-01-01 --cupid-base-startdate 0002-01-01 --cupid-base-enddate 0022-01-01 --adf-output-root "${CASEDIR}"/cupid-postprocessing --ldf-output-root "${CASEDIR}"/cupid-postprocessing --ilamb-output-root "${CASEDIR}"/cupid-postprocessing --cupid-run-adf TRUE --cupid-run-ldf FALSE --cupid-run-ilamb FALSE

./case.submit --only-job case.cupid

/glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142/tools/CUPiD/helper_scripts/generate_cupid_config_for_cesm_case.py --run-cvdp --case-root "${CASEDIR}" --cesm-root /glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142 --cupid-root /glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142/tools/CUPiD --cupid-example key_metrics --cupid-baseline-case b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271 --cupid-baseline-root /glade/derecho/scratch/hannay/archive --cupid-ts-dir /glade/derecho/scratch/hannay/archive/b.e30_alpha08a.B1850C_LTso.ne30_t232_wgx3.280/.. --cupid-startdate 0002-01-01 --cupid-enddate 0022-01-01 --cupid-base-startdate 0002-01-01 --cupid-base-enddate 0022-01-01 --adf-output-root "${CASEDIR}"/cupid-postprocessing --ldf-output-root "${CASEDIR}"/cupid-postprocessing --ilamb-output-root "${CASEDIR}"/cupid-postprocessing --cupid-run-adf TRUE --cupid-run-ldf FALSE --cupid-run-ilamb FALSE

./xmlchange CUPID_RUN_CVDP=FALSE

./xmlchange CUPID_RUN_ADF=TRUE

./case.submit --only-job case.cupid

/glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142/tools/CUPiD/helper_scripts/generate_cupid_config_for_cesm_case.py --case-root "${CASEDIR}" --cesm-root /glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142 --cupid-root /glade/work/hannay/cesm_tags/cesm3_0_alpha08a_cam6_4_142/tools/CUPiD --cupid-example key_metrics --cupid-baseline-case b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271 --cupid-baseline-root /glade/derecho/scratch/hannay/archive --cupid-ts-dir /glade/derecho/scratch/hannay/archive/b.e30_alpha08a.B1850C_LTso.ne30_t232_wgx3.280/.. --cupid-startdate 0002-01-01 --cupid-enddate 0022-01-01 --cupid-base-startdate 0002-01-01 --cupid-base-enddate 0022-01-01 --adf-output-root "${CASEDIR}"/cupid-postprocessing --ldf-output-root "${CASEDIR}"/cupid-postprocessing --ilamb-output-root "${CASEDIR}"/cupid-postprocessing --cupid-run-adf TRUE --cupid-run-ldf FALSE --cupid-run-ilamb FALSE

./xmlchange RESUBMIT=25,JOB_PRIORITY=regular

./xmlchange CUPID_STARTDATE=0002-01-01

./xmlchange CUPID_STOP_N=20

./xmlchange CUPID_BASE_STARTDATE=0002-01-01

./xmlchange CUPID_BASE_STOP_N=20

./xmlchange CUPID_BASELINE_CASE=b.e30_alpha07g.B1850C_LTso.ne30_t232_wgx3.271

./xmlchange CUPID_BASELINE_ROOT=/glade/derecho/scratch/hannay/archive

./xmlchange CUPID_EXAMPLE=key_metrics

./xmlchange CUPID_RUN_ALL=TRUE

./xmlchange CUPID_RUN_CVDP=FALSE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange CUPID_RUN_ALL=TRUE

./xmlchange CUPID_RUN_CVDP=TRUE

./xmlchange CUPID_RUN_ADF=TRUE

./xmlchange CUPID_RUN_LDF=TRUE

./xmlchange CUPID_BASE_STOP_N=20

./xmlchange CUPID_CLIMO_END_YEAR=21

./xmlchange CUPID_CLIMO_N_YEAR=20

