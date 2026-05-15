./case.setup

./case.build

./case.build

./case.submit

./xmlchange CONTINUE_RUN=TRUE

./xmlchange RESUBMIT=10

./case.submit

./xmlchange CASE_GIT_REPOSITORY=https://github.com/NCAR/cesm_dev

./xmlchange JOB_PRIORITY=regular

./case.build --clean-all

./case.build

./case.submit

./case.submit

