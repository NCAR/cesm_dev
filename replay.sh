./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange RESUBMIT=9

./xmlchange JOB_PRIORITY=special --force

./case.submit

./xmlchange RESUBMIT=9

./case.submit

./xmlchange RESUBMIT=5

./case.submit

