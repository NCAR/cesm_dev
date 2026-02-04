./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RESUBMIT=19

./case.build

./check_case

./xmlchange RESUBMIT=19

./xmlchange JOB_PRIORITY=premium

