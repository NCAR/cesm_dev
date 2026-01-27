./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./case.build

./xmlchange RESUBMIT=19

./xmlchange JOB_PRIORITY=premium

./check_case

./case.submit

./case.submit

./xmlchange RESUBMIT=0

