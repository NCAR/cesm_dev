# This file is for user convenience only and is not used by the model
# Changes to this file will be ignored and overwritten
# Changes to the environment should be made in env_mach_specific.xml
# Run ./case.setup --reset to regenerate this file
source /glade/u/apps/derecho/25.10/spack/opt/spack/lmod/8.7.55/gcc/12.5.0/uncg/lmod/lmod/init/csh
module load ncarenv/25.10 cesmdev/1.0
module purge 
module load conda/latest nco craype cmake intel/2025.3.2 mkl ncarcompilers/1.2.0 cray-mpich/8.1.32 netcdf-mpi/4.9.3 parallel-netcdf/1.14.1 parallelio/2.6.8 esmf-mpi/8.9.1
setenv OMP_STACKSIZE 64M
setenv FI_CXI_RX_MATCH_MODE hybrid
setenv FI_MR_CACHE_MONITOR memhooks
setenv ESMF_RUNTIME_PROFILE ON
setenv ESMF_RUNTIME_PROFILE_OUTPUT SUMMARY
