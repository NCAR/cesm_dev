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

CASENAME=b.e30_${cesmtag:(-8)}.${compset}.${useresoln}.cmip7-testing.009

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
stop_n=5
stop_option=nyears
resubmit=10

if [ "${USER}" == "cmip7" ]; then
    ########################
    ## connected as cmip7 user
    ########################
     echo $'\n----- Setting CMIP7 user defaults -----\n'
     do_git_archive=true
     do_download_code=true
     do_create_newcase=true
     do_case_setup=true
     do_case_build=false
     do_case_submit=false
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
    do_case_build=false
    do_case_submit=false
    do_tseries=false
    do_cupid=false
    do_cmor=false
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

fincl1 = 'ACTNL', 'ACTREL', 'AOA1', 'AOA_NH', 'AODABSdn', 'AODBCdn', 'AODdnDUST1', 'AODdnDUST2', 
'AODdnDUST3', 'AODPOMdn', 'AODSO4dn', 'AODSOAdn', 'AODSS', 'AODVISdn', 'AREA', 'AREI', 'AREL', 
'bc_a1', 'bc_a1DDF', 'bc_a1SFWET', 'bc_a4', 'bc_a4DDF', 'bc_a4SFWET', 'bc_c1DDF', 'bc_c1SFWET', 
'bc_c4DDF', 'bc_c4SFWET', 'BRY', 'BURDENSO4dn', 'BUTGWSPEC', 'C2H6', 'C3H6', 'C3H8', 'CDNUMC', 
'CH2O', 'CH3COCH3', 'CH4', 'CH4_CHML', 'ch4vmr', 'CLD_CAL', 'CLDHGH_CAL', 'CLDICE', 
'CLDICECON', 'CLDICESTR', 'CLDLIQ', 'CLDLIQCON', 'CLDLIQSTR', 'CLDLOW_CAL', 'CLDMED_CAL', 
'CLD_MISR', 'CLDTOT', 'CLDTOT_CAL', 'CLDTOT_ISCCP', 'CLOUD', 'CLY', 'CME', 'CMFDQ', 'CMFDT', 
'CMFMC', 'CMFMCDZM', 'CO', 'CO2', 'co2vmr', 'CO_CHML', 'column', 'CONCLD', 'DF_ALKNIT', 'DF_HNO3', 
'DF_HO2NO2', 'DF_HONITR', 'DF_ISOPNITA', 'DF_ISOPNITB', 'DF_NH3', 'DF_NH4', 'DF_NO', 'DF_NO2', 
'DF_NOA', 'DF_O3', 'DF_ONITR', 'DF_PAN', 'DF_SO2', 'DF_TERPNIT', 'DMS', 'DQSED', 
'dst_a1', 'dst_a1DDF', 'dst_a1SFWET', 'dst_a2', 'dst_a2DDF', 'dst_a2SFWET', 'dst_a3', 
'dst_a3DDF', 'dst_a3SFWET', 'dst_c1DDF', 'dst_c1SFWET', 'dst_c2DDF', 'dst_c2SFWET', 'dst_c3DDF', 
'dst_c3SFWET', 'DTCORE', 'EFLX_LH_TOT', 'EFLX_LH_TOT_ICE', 'EVAPPREC', 'EVAPQZM', 'EVAPTZM', 
'f11vmr', 'f12vmr', 'FCTL', 'FISCCP1_COSP', 'FLDS', 'FLDSC', 'FLNS', 'FLNT', 'FLUC', 'FLUT', 
'FLUTC', 'FREQI', 'FREQL', 'FREQZM', 'FSA', 'FSCSC', 'FSDS', 'FSDSC', 'FSH_ICE', 'FSNS', 'FSNSC', 
'FSNT', 'FSNTOA', 'FSNTOAC', 'FSR_ICE', 'FSUTOA', 'HCL', 'HNO3', 'HO2', 'ISOP', 'jno2', 'jo3_a', 
'KVH_CLUBB', 'LHFLX', 'LNO_PROD', 'MASS', 'MEANCLDALB_ISCCP', 'MEANPTOP_ISCCP', 'MEG_BCARY', 
'MEG_BIGALK', 'MEG_BIGENE', 'MEG_C2H4', 'MEG_C2H5OH', 'MEG_C2H6', 'MEG_C3H6', 'MEG_C3H8', 
'MEG_CH2O', 'MEG_CH3CHO', 'MEG_CH3COCH3', 'MEG_CH3COOH', 'MEG_CH3OH', 'MEG_CO', 'MEG_HCN', 
'MEG_HCOOH', 'MEG_ISOP', 'MEG_MTERP', 'MEG_TOLUENE', 'N2O', 'N2O_CHML', 'n2ovmr', 'ncl_a1', 
'ncl_a1DDF', 'ncl_a1SFWET', 'ncl_a2', 'ncl_a2DDF', 'ncl_a2SFWET', 'ncl_a3', 
'ncl_a3DDF', 'ncl_c1', 'ncl_c1DDF', 'ncl_c1SFWET', 'ncl_c2', 'ncl_c2DDF', 'ncl_c2SFWET', 
'ncl_c3', 'ncl_c3DDF', 'ncl_c3SFWET', 'NH4', 'NH_50', 'NO', 'NO2', 'NO2_CLXF', 'NO2_SRF', 
'NOY', 'num_a1', 'num_a2', 'num_a3', 'num_a4', 'NUMLIQ', 'O3', 'O3_Loss', 'O3_Prod', 'O3S', 
'O3_SRF', 'OH', 'OMEGA', 'PAN', 'PBLH', 'PM25', 'PM25_SRF', 'pom_a1', 'pom_a1DDF', 'pom_a1SFWET', 
'pom_a4', 'pom_a4DDF', 'pom_a4SFWET', 'pom_c1DDF', 'pom_c1SFWET', 'pom_c4DDF', 'pom_c4SFWET', 
'PRECC', 'PRECT', 'PS', 'PSL', 'PTEQ', 'PTTEND', 'Q', 'QAP', 'QFLX', 'QFLX_EVAP_TOT', 
'QREFHT', 'QRL', 'QRLC', 'QRS', 'QRSC', 'QSNOW', 'RAIN', 'RAIN_ICE', 'RELHUM', 'RHREFHT', 
'SFbc_a4', 'SFBENZENE', 'SFBIGALK', 'SFBIGENE', 'SFC2H2', 'SFC2H4', 'SFC2H5OH', 'SFC2H6', 
'SFC3H6', 'SFC3H8', 'SFCH2O', 'SFCH3CHO', 'SFCH3COCH3', 'SFCH3COCHO', 'SFCH3COOH', 'SFCH3OH', 
'SFCO', 'SFDMS', 'SFdst_a1', 'SFdst_a2', 'SFdst_a3', 'SFGLYALD', 'SFHCOOH', 'SFISOP', 'SFMEF', 
'SFMTERP', 'SFncl_a1', 'SFncl_a2', 'SFncl_a3', 'SFNH3', 'SFNO', 'SFNO2', 'SFpom_a4', 
'SFSO2', 'SFso4_a1', 'SFso4_a2', 'SFTOLUENE', 'SFXYLENES', 'SHFLX', 'SNOW', 'SO2', 
'SO2_CLXF', 'so4_a1', 'so4_a1_CLXF', 'so4_a1DDF', 'so4_a1_sfgaex1', 'so4_a1SFWET', 
'so4_a2', 'so4_a2_CLXF', 'so4_a2DDF', 'so4_a2_sfgaex1', 'so4_a2SFWET', 'so4_a3', 'so4_a3DDF', 
'so4_a3_sfgaex1', 'so4_a3SFWET', 'so4_c1AQH2SO4', 'so4_c1AQSO4', 'so4_c1DDF', 'so4_c1SFWET', 
'so4_c2AQH2SO4', 'so4_c2AQSO4', 'so4_c2DDF', 'so4_c2SFWET', 'so4_c3AQH2SO4', 'so4_c3AQSO4', 
'so4_c3DDF', 'so4_c3SFWET', 'soa1_a1', 'soa1_a1_sfgaex1', 'soa1_a2', 'soa1_a2_sfgaex1', 
'soa2_a1', 'soa2_a1_sfgaex1', 'soa2_a2', 'soa2_a2_sfgaex1', 'soa3_a1', 'soa3_a1_sfgaex1', 'soa3_a2', 
'soa3_a2_sfgaex1', 'soa4_a1', 'soa4_a1_sfgaex1', 'soa4_a2', 'soa4_a2_sfgaex1', 'soa5_a1', 
'soa5_a1_sfgaex1', 'soa5_a2', 'soa5_a2_sfgaex1', 'soa_a1DDF', 'soa_a1_sfgaex1', 
'soa_a1SFWET', 'soa_a2DDF', 'soa_a2_sfgaex1', 'soa_a2SFWET', 'soa_c1DDF', 'soa_c1SFWET', 
'soa_c2DDF', 'soa_c2SFWET', 'SOLIN', 'SOLLD', 'SOLSD', 'T', 'TAQ', 'TAUBLJX', 'TAUBLJY', 'TAUGWX', 
'TAUGWY', 'TAUX', 'TAUY', 'TGCLDIWP', 'TGCLDLWP', 'TG_ICE', 'THzm', 'TMO3', 'TMQ', 'TOT_CLD_VISTAU', 
'TREFHT', 'TREFHTMN', 'TREFHTMX', 'TROP_P', 'TROP_T', 'TROP_Z', 'TS', 'TTEND_TOT', 'TTGWORO', 
'TTGWSPEC', 'U', 'U10', 'UTGWORO', 'UTGWSPEC', 'UVzm', 'UWzm', 'Uzm', 'V', 'VD01', 'VTHzm', 
'Vzm', 'WD_NH3', 'WD_NH4', 'WD_NOY', 'WD_SO2', 'Wzm', 'Z3', 'ZMDQ', 'ZMDT', 'ZMMTT', 'ZMMU'

EOF


if [[ $do_dy == true ]]; then
cat <<EOF>> user_nl_cam

! daily
fincl2 = 'ACTNL', 'ACTREL', 'AODVISdn', 'bc_a1', 'bc_a4', 'BURDENBCdn', 'BURDENDUSTdn', 'BURDENPOMdn', 
'BURDENSEASALTdn', 'BURDENSO4dn', 'BURDENSOAdn', 'BUTGWSPEC', 'CDNUMC', 'CLD_CAL', 'CLDHGH_CAL', 'CLDICE', 
'CLDLIQ', 'CLDLOW_CAL', 'CLDMED_CAL', 'CLDTOT', 'CLDTOT_CAL', 'CLDTOT_ISCCP', 'CLOUD', 'CO', 'DF_ALKNIT', 
'DF_HNO3', 'DF_HO2NO2', 'DF_HONITR', 'DF_ISOPNITA', 'DF_ISOPNITB', 'DF_NH3', 'DF_NH4', 'DF_NO', 'DF_NO2', 
'DF_NOA', 'DF_ONITR', 'DF_PAN', 'DF_TERPNIT', 'dst_a1', 'dst_a2', 'dst_a3', 'EFLX_LH_TOT', 'EFLX_LH_TOT_ICE', 
'FCTL', 'FISCCP1_COSP', 'FLASHFRQ', 'FLDS', 'FLDSC', 'FLNS', 'FLUC', 'FLUT', 'FLUTC', 'FSA', 'FSCSC', 'FSDS', 
'FSDSC', 'FSH_ICE', 'FSNS', 'FSNSC', 'FSNTOA', 'FSNTOAC', 'FSR_ICE', 'FSUTOA', 'LHFLX', 'MEANCLDALB_ISCCP', 
'MEANPTOP_ISCCP', 'ncl_a1', 'ncl_a2', 'ncl_a3', 'ncl_c1', 'ncl_c2', 'ncl_c3', 'NH4', 'O3_SRF', 'OMEGA', 'OMEGA500', 
'PM25_SRF', 'pom_a1', 'pom_a4', 'PR', 'PRECC', 'PRECT', 'PS', 'PSIRS', 'PSL', 'PTTEND', 'Q', 'QFLX', 'QFLX_EVAP_TOT', 
'QFLX_SNOW_DRAIN', 'QREFHT', 'QRL', 'QRS', 'QSNOFRZ', 'QSNOW', 'RAIN', 'RAIN_ICE', 'RELHUM', 'RHREFHT', 'SHFLX', 
'SNOCAN', 'SNOW', 'SO2', 'so4_a1', 'so4_a2', 'so4_a3', 'soa1_a1', 'soa1_a2', 'soa2_a1', 'soa2_a2', 'soa3_a1', 
'soa3_a2', 'soa4_a1', 'soa4_a2', 'soa5_a1', 'soa5_a2', 'SOLIN', 'SOLLD', 'SOLSD', 'T', 'T700', 'T850', 'TAUBLJX', 
'TAUBLJY', 'TAUGWX', 'TAUGWY', 'TAUX', 'TAUY', 'TGCLDIWP', 'TGCLDLWP', 'THzm', 'TMO3', 'TMQ', 'TOT_CLD_VISTAU', 
'TREFHT', 'TREFHTMN', 'TREFHTMX', 'TREFMNAV', 'TREFMXAV', 'TS', 'U', 'U10', 'UTGWORO', 'UTGWSPEC', 'UVzm', 'UWzm', 
'Uzm', 'V', 'VTHzm', 'Vzm', 'WD_NH3', 'WD_NH4', 'WD_NOY', 'Wzm', 'Z1000', 'Z3', 'Z500', 'ZMFLXSNW'

EOF

fi

if [[ $do_hr6 == true ]]; then
cat <<EOF>> user_nl_cam

! 6 hourly
fincl3 = 'FLDS', 'FSDS', 'PRECT', 'PSL', 'PS', 'QREFHT', 'RAIN', 'SNOW', 'RHREFHT', 
'TMQ', 'TREFHT', 'TS', 'U', 'U10', 'V', 'Z1000', 'Z3', 'Z500', 'Z700', 'Z925', 
'PRECTMX', 'RELHUM100', 'RELHUM500', 'RELHUM850', 'Q', 'UREFHT', 'VREFHT'

EOF

fi

if [[ $do_hr3 == true ]]; then
cat <<EOF>> user_nl_cam

! 3 hourly
fincl4 = 'QREFHT', 'PRECT', 'SNOW', 'PS', 'FLDS', 'FSDS', 'TREFHT', 'RHREFHT', 
'num_a1', 'num_a2', 'num_a3', 'num_a4', 'bc_a1', 'bc_a4', 'dst_a1', 'dst_a2', 'dst_a3', 
'NH4', 'pom_a1', 'pom_a4', 'soa1_a1', 'soa1_a2', 'soa2_a1', 'soa2_a2', 'soa3_a1', 
'soa3_a2', 'soa4_a1', 'soa4_a2', 'soa5_a1', 'soa5_a2', 'so4_a1', 'so4_a2', 'so4_a3', 
'ncl_a1', 'ncl_a2', 'ncl_a3', 'ncl_c1', 'ncl_c2', 'ncl_c3', 'SO2', 'U10'

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
ln -s /glade/derecho/scratch/gmarques/for_cecile/198/INPUT/* .

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

