./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./preview_namelists

./xmlchange RESUBMIT=9

./case.submit

./pelayout

./xmlchange RESUBMIT=0

./xmlchange RESUBMIT=0

