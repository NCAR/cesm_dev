./case.setup

./xmlchange CASE_GIT_REPOSITORY=git@github.com:NCAR/cesm_dev.git

./case.build

./xmlchange RESUBMIT=19

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/u/home/igrooms/runoff_mapping/map_r05_to_tx2_3_ad_hoc_260210.nc

./check_case

./case.submit

./xmlchange RESUBMIT=0

./xmlchange CONTINUE_RUN=False

./xmlchange RESUBMIT=19

./xmlchange ROF2OCN_ICE_RMAPNAME=/glade/u/home/igrooms/runoff_mapping/map_r05_to_tx2_3_nnsm_e250r250_modified_260212.nc

./case.setup --reset

./xmlchange PROJECT=CESM0023

./case.build

./check_case

./case.submit

