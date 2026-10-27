./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./xmlchange RESUBMIT=25

./case.build

./check_case

./xmlchange RUN_REFDATE=0049-01-01

./check_case

./check_case

./case.submit

./xmlchange RESUBMIT=0

