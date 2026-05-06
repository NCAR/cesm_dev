./case.setup

./case.build

./case.submit

./case.submit

./xmlchange CONTINUE_RUN=TRUE

./xmlchange RESUBMIT=10

./case.submit

./xmlchange RESUBMIT=2

./case.submit

./xmlchange PROJECT=CESM0027

./xmlchange CASE_GIT_REPOSITORY=https://github.com/NCAR/cesm_dev

