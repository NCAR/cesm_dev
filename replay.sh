./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange JOB_PRIORITY=special --force

./case.build

./check_case

./xmlchange RESUBMIT=10

./xmlchange JOB_PRIORITY=special --force

./case.submit

