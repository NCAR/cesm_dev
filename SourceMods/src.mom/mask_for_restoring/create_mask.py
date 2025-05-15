import xarray as xr
import netCDF4 as nc

# File and variable names
source_file = "/glade/work/gmarques/cesm/tx2_3/basin_masks/basin_masks_tx2_3v2_20250318.nc"
target_file = "salt_restore_mask.nc"
var_name = "mask"  # name of the variable to copy/overwrite

# Step 1: Read variable from source file using xarray
src_ds = xr.open_dataset(source_file)
data_to_copy = src_ds['basin_masks'].sel(region='LabSea').values  # just the raw data array

# Step 2: Overwrite variable in target file using netCDF4
dst_nc =nc.Dataset(target_file, mode='r+')

if var_name not in dst_nc.variables:
    raise KeyError(f"Variable '{var_name}' not found in {target_file}")

dst_var = dst_nc.variables[var_name]

# Check shape compatibility
if dst_var.shape != data_to_copy.shape:
    raise ValueError(f"Shape mismatch: {dst_var.shape} (target) vs {data_to_copy.shape} (source)")

# Overwrite data
dst_var[:] = data_to_copy

dst_nc.sync()
dst_nc.close()

print(f"Variable '{var_name}' successfully overwritten in {target_file}")

