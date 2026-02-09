./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange RESUBMIT=19

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100_250327.nc

./xmlchange ROF2OCN_LIQ_RMAPNAME=/glade/work/gmarques/cesm/tx2_3/runoff_mapping/map_r05_to_tx2_3_nnsm_e100r100_250327.nc

./check_case

./xmlchange JOB_PRIORITY=premium

./case.submit

./case.submit

