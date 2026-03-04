./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange RESUBMIT=19

./preview_namelists

./check_case

./case.submit

./xmlchange RESUBMIT=9

./case.submit

./xmlchange RESUBMIT=9

