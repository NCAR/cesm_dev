./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./case.build

./xmlchange JOB_PRIORITY=regular

./xmlchange RESUBMIT=10

./check_case

./case.submit

./case.submit

./xmlchange JOB_PRIORITY=special --force

