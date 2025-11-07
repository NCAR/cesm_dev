#!/bin/csh

echo "Checking emission files..."

set missing = 0

# List of files from ext_frc_specifier and srf_emis_specifier
set files = ( \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/bc_a4-em-AIR-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/num_bc_a4-em-AIR-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/SO2-em-AIR-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/so4_a1_ene_vertical-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/num_so4_a1_ene_vertical-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/cesm/cesmdata/inputdata/atm/cam/chem/emis/historical_ne30pg3/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_ne30pg3_c20200125.nc \
/glade/campaign/cesm/cesmdata/inputdata/atm/cam/chem/emis/historical_ne30pg3/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_ne30pg3_c20200125.nc \
/glade/campaign/cesm/cesmdata/inputdata/atm/cam/chem/emis/historical_ne30pg3/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_ne30pg3_c20200125.nc \
/glade/campaign/cesm/cesmdata/inputdata/atm/cam/chem/emis/historical_ne30pg3/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_ne30pg3_c20200125.nc \
/glade/campaign/cesm/cesmdata/inputdata/atm/cam/chem/emis/historical_ne30pg3/emissions-cmip6_SO2_contvolcano_vertical_850-5000_ne30pg3_c20200125.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/bc_a4-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/bc_a4_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/pom_a4-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/pom_a4_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/num_bc_a4-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/num_bc_a4_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/num_pom_a4-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/num_pom_a4_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/num_so4_a1_ag-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/num_so4_a1_ship_slv-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/num_so4_a2_res_trs-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/so4_a1_ag_ship_slv-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/so4_a2_res_trs-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/SO4_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/num_SO4_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/SO2-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/SO2_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/ISOP_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/BENZENE_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/BENZENE-VOC-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18-supplemental_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/IVOC_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/IVOC-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/SVOC_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/SVOC-em-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/TOLUENE_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/TOLUENE-VOC-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18-supplemental_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/XYLENES_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/CEDS-CMIP-2025-04-18_20251030/XYLENES-VOC-anthro_input4MIPs_emissions_CMIP_CEDS-CMIP-2025-04-18-supplemental_gn_175001-202312_c20251030.nc \
/glade/campaign/acom/MUSICA/emis/cmip7/ne30/DRES-CMIP-BB4CMIP7-2-0_smoothed_20251102/MTERP_smoothed_input4MIPs_emissions_CMIP_DRES-CMIP-BB4CMIP7-2-0_gn_175001-202112_c20251102.nc \
)

foreach f ( $files )
    if ( -e $f ) then
        echo "Found: $f"
    else
        echo "Missing: $f"
        @ missing++
    endif
end

echo "-----------------------------"
if ( $missing == 0 ) then
    echo "All files are present."
else
    echo "$missing file(s) missing."
endif
