./case.setup

./xmlchange RESUBMIT=25

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./check_case

./case.submit

