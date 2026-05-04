./case.setup

./case.build

./xmlchange PROJECT=P93300065

./xmlchange JOB_PRIORITY=regular

./case.submit

./case.submit

./xmlchange CONTINUE_RUN=TRUE

./xmlchange RESUBMIT=10

./case.submit

./case.submit

./case.submit

./xmlchange PROJECT=CESM0027

./xmlchange RUN_TYPE=hybrid

./xmlchange CONTINUE_RUN=FALSE

./xmlchange RESUBMIT=0

./case.submit

./xmlchange CONTINUE_RUN=TRUE

./xmlchange RESUBMIT=10

./case.submit

./xmlchange JOB_PRIORITY=premium

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange CASE_GIT_REPOSITORY=https://github.com/NCAR/cesm_dev.git

./xmlchange CASE_GIT_REPOSITORY=https://github.com/NCAR/cesm_dev.git

