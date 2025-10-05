./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./case.build

./check_case

./xmlchange RESUBMIT=9

./check_case

./case.submit

./case.submit

