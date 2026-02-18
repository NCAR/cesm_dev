# This file is for user convenience only and is not used by the model
# Changes to this file will be ignored and overwritten
# Changes to the environment should be made in env_mach_specific.xml
# Run ./case.setup --reset to regenerate this file
source /glade/u/apps/derecho/24.12/spack/opt/spack/lmod/8.7.37/gcc/12.4.0/nr3e/lmod/lmod/init/csh
module load cesmdev/1.0 ncarenv/24.12
module purge 
module load conda/latest nco craype cmake intel/2024.2.1 mkl kokkos/4.2.01 ncarcompilers/1.0.0 cray-mpich/8.1.29 netcdf-mpi/4.9.3 parallel-netcdf/1.14.0 parallelio/2.6.6 esmf/8.9.0
setenv OMP_STACKSIZE 64M
setenv FI_CXI_RX_MATCH_MODE hybrid
setenv FI_MR_CACHE_MONITOR memhooks
setenv ESMF_RUNTIME_PROFILE ON
setenv ESMF_RUNTIME_PROFILE_OUTPUT SUMMARY
