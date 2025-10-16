./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange JOB_PRIORITY=special --force

./case.build

./check_case

./xmlchange RESUBMIT=10

./xmlchange JOB_PRIORITY=special --force

./case.submit

./case.submit

./xmlchange RESUBMIT=0

./case.submit

./xmlchange RESUBMIT=4

./xmlchange RESUBMIT=9

