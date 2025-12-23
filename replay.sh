./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./check_case

./case.submit

./xmlchange CONTINUE_RUN=True,RESUBMIT=9

./case.submit

./xmlchange RESUBMIT=9

./case.submit

