#!/bin/bash

# ======================================================
# CMIP7 LTso TEMPLATE SCRIPT
# Modify indicated sections
# ====================================================== 

########################
##  Case details
########################
cesmtag=cesm3_0_alpha07f
project=CESM0024
compset=B1850C_LTso 
resolution=ne30pg3_t232_wg37
useresoln=ne30_t232_wgx3

git_repo=git@github.com:NCAR/cesm_dev.git

CASENAME=b.e30_${cesmtag:(-8)}.${compset}.${useresoln}.cmip7-testing.010

echo "creating $CASENAME"

########################
## Set atm output frequency
########################
do_hr3=true
do_hr6=true
do_dy=true

########################
## Set run instructions
########################
stop_n=2
stop_option=nyears
resubmit=5

if [ "${USER}" == "cmip7" ]; then
    ########################
    ## connected as cmip7 user
    ########################
     echo $'\n----- Setting CMIP7 user defaults -----\n'
     do_git_archive=true
     do_download_code=false
     do_create_newcase=true
     do_case_setup=true
     do_case_build=true
     do_case_submit=true
     do_tseries=true
     do_cmor=true
     do_cupid=true
     casedir=$WORK/cases/testing/
     CODE_ROOT=$WORK/cesm_tags/
else
    ########################
    ## Set flags to do stuff ----
    ########################
    do_git_archive=true
    do_download_code=false
    do_create_newcase=true
    do_case_setup=true
    do_case_build=true
    do_case_submit=true
    do_tseries=true
    do_cupid=false
    do_cmor=true
    casedir=$SCRATCH/workflow_testcase/
    CODE_ROOT=$SCRATCH/cesm_tags/
fi
CASEROOT=$casedir/$CASENAME

########################
## Set Case Details
########################

########################
## Clone the repository
########################
path=${CODE_ROOT}/${cesmtag}

if [[ $do_download_code != true || -d "${path}" ]]; then
     echo $'\n----- Skipping code download -----\n'
else
     mkdir -p ${CODE_ROOT}
     echo $'\n----- Downloading CESMROOT -----\n'

     cd ${CODE_ROOT}

     # clone the repo and get the cesm tag
     git clone https://github.com/ESCOMP/cesm $cesmtag -b $cesmtag
     cd $cesmtag

     # check out the components
     ./bin/git-fleximod update

     ### START ----- Remove when we are in production
     ###############################################
     ## Update the ccs_config to the workflow branch
     ###############################################
     cd ccs_config
     git checkout add_cmip7_workflow_amon_basic
     ### END ----- Remove when we are in production

fi

########################
## Create new case
########################
if [[ $do_create_newcase != true ]]; then
     echo $'\n----- Skipping create_newcase -----\n'
else
    path=${CASEROOT}
    if [ -d "${path}" ]; then
        echo "ERROR: CASE Directory already exists. Not overwriting"
        exit 20
    fi
    if [[ $do_cmor == true || $do_tseries == true ]]; then
        add_workflow="--workflow cmip7"
    else
        add_workflow=""
    fi
    ${CODE_ROOT}/${cesmtag}/cime/scripts/create_newcase \
        --case ${CASEROOT}  \
        --compset ${compset} \
	$add_workflow        \
	--res ${resolution} \
        --run-unsupported  \
	--project ${project} 
fi

########################
## copy script to CASEROOT directory
########################
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
SCRIPT_NAME="$(basename "$SCRIPT_PATH")"

mkdir -p "${CASEROOT}/provenance_script"
cp "$SCRIPT_PATH" "${CASEROOT}/provenance_script/$SCRIPT_NAME"


########################
## Set up 
########################
cd ${CASEROOT}
./case.setup

########################
## namelists
########################
 
# Edit each of the cmip7 workflow scripts to specify options to skip cmor or timeseries generation
# if both are false these files won't exist in the case directory
cmfiles=(".amon" ".lmon")
for f in "${cmfiles[@]}"; do
  if [[ -f "$f" ]]; then
      if [[ $do_cmor == false ]]; then
          echo "add skip-cmor option in $f"
          sed -i 's/--caseroot/--skip-cmor --caseroot/g' "$f"
      fi
      if [[ $do_tseries == false ]]; then
          echo "add skip-timeseries option in $f"
          sed -i 's/--caseroot/--skip-timeseries --caseroot/g' "$f"
      fi
  fi
done

date=`date "+%Y-%m-%d %H:%M:%S"`

if [ "${USER}" == "cmip7" ]; then
    echo "$date: Created in cmip7 account by $SUDO_USER" >> CaseStatus
else
    echo "$date: Created by $USER" >> CaseStatus
fi
echo " ---------------------------------------------------" >> CaseStatus

########################
## user_nl_cam
########################

mv user_nl_cam user_nl_cam-OTB

cat <<EOF> user_nl_cam
mfilt               =       0,       5,     20,      40,   
nhtfrq              =       0,     -24,     -6,      -3,      
ndens               =       2,       2,      2,       2,      
interpolate_output  =  .false.,  .false., .false.,  .false.

empty_htapes = .true.

fincl1 = 'ACTNL', 'ACTREL', 'AODABSdn', 'AODBCdn', 'AODPOMdn', 'AODSO4dn', 'AODSOAdn', 'AODSS', 'AODVISdn', 'AREA', 'AREI',
'AREL', 'bc_a1', 'bc_a1DDF', 'bc_a1SFWET', 'bc_a4', 'bc_a4DDF', 'bc_a4SFWET', 'bc_c1DDF', 'bc_c1SFWET', 'bc_c4DDF','bc_c4SFWET',
'BURDENSO4dn', 'BUTGWSPEC', 'CDNUMC', 'CH4', 'CH4_CHML', 'CLDICE', 'CLDLIQ', 'CLDTOT', 'CLOUD', 'CME', 'CMFMC', 'CO2',  'CONCLD',
'DF_SO2', 'DMS', 'dst_a1', 'dst_a1DDF', 'dst_a1SFWET', 'dst_a2', 'dst_a2DDF', 'dst_a2SFWET', 'dst_a3', 'dst_a3DDF', 'dst_a3SFWET',
'dst_c1DDF', 'dst_c1SFWET', 'dst_c2DDF', 'dst_c2SFWET', 'dst_c3DDF', 'dst_c3SFWET', 'DTCORE', 'EVAPPREC', 'EVAPQZM', 'EVAPTZM',
'FCTL', 'FLDS', 'FLDSC', 'FLNS', 'FLNT', 'FLUT', 'FLUTC', 'FREQI', 'FREQL', 'FREQZM', 'FSDS', 'FSDSC', 'FSNS', 'FSNSC', 'FSNT',
'FSNTOA', 'FSNTOAC', 'FSUTOA', 'HO2', 'KVH_CLUBB', 'LHFLX', 'MASS', 'N2O', 'N2O_CHML', 'ncl_a1', 'ncl_a1DDF', 'ncl_a1SFWET',
'ncl_a2', 'ncl_a2DDF', 'ncl_a2SFWET', 'ncl_a3', 'ncl_a3DDF', 'ncl_c1', 'ncl_c1DDF', 'ncl_c1SFWET', 'ncl_c2', 'ncl_c2DDF',
'ncl_c2SFWET', 'ncl_c3', 'ncl_c3DDF', 'ncl_c3SFWET', 'NOY', 'num_a1', 'num_a2', 'num_a3', 'num_a4', 'NUMLIQ', 'O3', 'OH',
'OMEGA', 'PBLH', 'PM25', 'PM25_SRF', 'pom_a1', 'pom_a1DDF', 'pom_a1SFWET', 'pom_a4', 'pom_a4DDF', 'pom_a4SFWET',
'pom_c1DDF', 'pom_c1SFWET', 'pom_c4DDF', 'pom_c4SFWET', 'PRECC', 'PRECT', 'PS', 'PSL', 'PTEQ', 'PTTEND', 'Q', 'QAP',
'QFLX', 'QREFHT', 'QRL', 'QRLC', 'QRS', 'QRSC', 'QSNOW', 'RELHUM', 'RHREFHT', 'SFbc_a4', 'SFDMS', 'SFdst_a1', 'SFdst_a2',
'SFdst_a3', 'SFncl_a1', 'SFncl_a2', 'SFncl_a3', 'SFpom_a4', 'SFSO2', 'SFso4_a1', 'SFso4_a2', 'SHFLX', 'SO2', 'SO2_CLXF',
'so4_a1', 'so4_a1_CLXF', 'so4_a1DDF', 'so4_a1_sfgaex1', 'so4_a1SFWET', 'so4_a2', 'so4_a2_CLXF', 'so4_a2DDF', 'so4_a2_sfgaex1',
'so4_a2SFWET', 'so4_a3', 'so4_a3DDF', 'so4_a3_sfgaex1', 'so4_a3SFWET', 'so4_c1AQH2SO4', 'so4_c1AQSO4', 'so4_c1DDF', 'so4_c1SFWET',
'so4_c2AQH2SO4', 'so4_c2AQSO4', 'so4_c2DDF', 'so4_c2SFWET', 'so4_c3AQH2SO4', 'so4_c3AQSO4', 'so4_c3DDF', 'so4_c3SFWET',
'soa_a1DDF', 'soa_a1_sfgaex1', 'soa_a1SFWET', 'soa_a2DDF', 'soa_a2_sfgaex1', 'soa_a2SFWET', 'soa_c1DDF', 'soa_c1SFWET',
'soa_c2DDF', 'soa_c2SFWET', 'SOLIN', 'SOLLD', 'SOLSD', 'T', 'TAQ', 'TAUBLJX', 'TAUBLJY', 'TAUGWX', 'TAUGWY', 'TAUX', 'TAUY',
'TGCLDIWP', 'TGCLDLWP', 'TMQ', 'TOT_CLD_VISTAU', 'TREFHT', 'TREFHTMN', 'TREFHTMX', 'TROP_P', 'TROP_T', 'TROP_Z', 'TS',
'TTEND_TOT', 'TTGWORO', 'TTGWSPEC', 'U', 'U10', 'UTGWORO', 'UTGWSPEC', 'V', 'VD01', 'WD_SO2', 'Z3', 'ZMDQ', 'ZMDT', 'ZMMTT', 
'ZMMU'

EOF


if [[ $do_dy == true ]]; then
cat <<EOF>> user_nl_cam

! daily

fincl2 = 'ACTNL', 'ACTREL', 'AODVISdn', 'bc_a1', 'bc_a4', 'BURDENBCdn', 'BURDENDUSTdn', 'BURDENPOMdn',
'BURDENSEASALTdn', 'BURDENSO4dn', 'BURDENSOAdn', 'BUTGWSPEC', 'CDNUMC', 'CLDICE', 'CLDLIQ', 'CLDTOT',
'CLOUD', 'OMEGA', 'OMEGA500', 'PM25_SRF', 'pom_a1', 'pom_a4', 'PRECC', 'PRECT', 'PS', 'PSL', 'PTTEND',
'Q', 'QFLX', 'QRL', 'QRS', 'QSNOW', 'RELHUM', 'RHREFHT', 'SHFLX', 'SO2', 'so4_a1', 'so4_a2', 'so4_a3',
'SOLIN', 'SOLLD', 'SOLSD', 'T', 'T700', 'T850', 'TAUBLJX', 'TAUBLJY', 'TAUGWX', 'TAUGWY', 'TAUX', 'TAUY',
'TGCLDIWP', 'TGCLDLWP', 'TMQ', 'TOT_CLD_VISTAU', 'TREFHT', 'TREFHTMN', 'TREFHTMX', 'TREFMNAV', 'TREFMXAV',
'TS', 'U', 'U10', 'UTGWORO', 'UTGWSPEC', 'V', 'Z1000', 'Z3', 'Z500', 'ZMFLXSNW'

EOF

fi

if [[ $do_hr6 == true ]]; then
cat <<EOF>> user_nl_cam

! 6 hourly
fincl3 = 'FLDS', 'FSDS', 'PRECT', 'PSL', 'PS', 'QREFHT', 'RHREFHT', 'TMQ', 'TREFHT',
'TS', 'U', 'U10', 'V', 'Z1000', 'Z3', 'Z500', 'Z700', 'PRECTMX', 'Q'
EOF

fi

if [[ $do_hr3 == true ]]; then
cat <<EOF>> user_nl_cam

! 3 hourly
fincl4 = 'QREFHT', 'PRECT', 'PS', 'FLDS', 'FSDS', 'TREFHT', 'RHREFHT', 'num_a1', 'num_a2',
'num_a3', 'num_a4', 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 'pom_a1', 'pom_a4', 'so4_a1',
'so4_a2', 'so4_a3', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'ncl_c1', 'ncl_c2', 'ncl_c3', 'SO2', 'U10'

EOF

fi

########################
## user_nl_clm
########################

cat <<EOF> user_nl_clm
reseed_dead_plants = .true.
EOF

cat <<EOF> user_nl_cpl
histaux_l2x1yrg = .true.
EOF

cat <<EOF> user_nl_cice
EOF

cat <<EOF> user_nl_mom
EOF


########################
## START TEMPORARY SECTION
## won't need by the time we are in production
###---------------------

mkdir -p $SCRATCH/${CASENAME}/run/INPUT
cd $SCRATCH/${CASENAME}/run/INPUT
#ln -s /glade/derecho/scratch/gmarques/for_cecile/198/INPUT/* .

###---------------------
## END TEMP SECTION
#########################33

cd $CASEROOT
./preview_namelists

########################
## add to github repo
########################
if [[ $do_git_archive == true ]]; then
    cd ${CASEROOT}  
    cp $curdir
    ./xmlchange CASE_GIT_REPOSITORY=$git_repo

fi

########################
## timeseries
########################
if [[ $do_tseries == true ]]; then
   ## => the timeseries will be part of pf the workflow 
   echo "do_tseries == $do_tseries"
fi

########################
## CUPID
########################
if [[ $do_cupid == true ]]; then
   echo "do_cupid == $do_cupid"
   ./xmlchange RUN_POSTPROCESSING=TRUE
fi


########################
## CMORization
########################
if [[ $do_cmor == true ]]; then
   ## => CMORization
   echo "do_cmor == $do_cmor"
fi

########################
## build and submit
########################

cd ${CASEROOT}
./xmlchange JOB_PRIORITY=premium
./xmlchange RESUBMIT=${resubmit},STOP_N=${stop_n},STOP_OPTION=${stop_option}
./xmlchange REST_OPTION=nyears,REST_N=1

if [[ $do_case_build == true ]]; then
   qcmd -A ${project} -- ./case.build
fi
if [[ $do_case_submit == true ]]; then
   ./case.submit
fi

