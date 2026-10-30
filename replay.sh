./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange RESUBMIT=4

./preview_namelists

./case.submit

./xmlchange RESUBMIT=10

./case.submit

./pelayout

./xmlchange RESUBMIT=12

