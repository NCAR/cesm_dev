./case.setup

./case.build

./xmlchange PROJECT=P93300065

./xmlchange JOB_PRIORITY=regular

./case.submit

./case.submit

./xmlchange CONTINUE_RUN=TRUE

./xmlchange RESUBMIT=10

./case.submit

