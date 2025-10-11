./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./case.build

./xmlchange RESUBMIT=10

./case.submit

./check_case

./case.submit

