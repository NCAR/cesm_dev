
# This file is auto-generated, do not edit. If you want to change
# sharedlib flags, you can edit the cmake_macros in this case. You
# can change flags for specific sharedlibs only by checking COMP_NAME.

CFLAGS :=  -qno-opt-dynamic-align -fp-model precise -std=gnu99 -O0 -no-fma -g -qopt-report -march=core-avx2
CMAKE_OPTS := -DCMAKE_SYSTEM_NAME=Catamount
CONFIG_ARGS := --host=cray
CPPDEFS := $(CPPDEFS)  -DCESMCOUPLED -DFORTRANUNDERSCORE -DCPRINTEL -DLINUX -DHAVE_GETTID
CXXFLAGS :=  -qno-opt-dynamic-align -fp-model precise -std=c++17 -O0 -no-fma -g -traceback -qopt-report -march=core-avx2
CXX_LDFLAGS :=  -cxxlib
CXX_LINKER := FORTRAN
FC_AUTO_R8 := -r8
FFLAGS :=  -O0 -no-fma -g -check uninit -check bounds -check pointers -fpe0 -check noarg_temp_created -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source -qopt-report -march=core-avx2
FFLAGS_NOOPT := -O0
FIXEDFLAGS := -fixed
FREEFLAGS := -free
MACRO_FILE := 
MPICC := cc
MPICXX := CC
MPIFC := ftn
MPI_SERIAL_PATH := 
NETCDF_PATH := /glade/u/apps/derecho/24.12/spack/opt/spack/netcdf/4.9.3/cray-mpich/8.1.29/oneapi/2024.2.1/rjvv
PIO_FILESYSTEM_HINTS := lustre
PIO_INCDIR := /glade/u/apps/cseg/derecho/24.12/spack/opt/spack/linux-sles15-x86_64_v3/oneapi-2024.2.1/parallelio-2.6.6-fisdggccpiiuzlshmernllyvvakay3ms/include
PIO_LIBDIR := /glade/u/apps/cseg/derecho/24.12/spack/opt/spack/linux-sles15-x86_64_v3/oneapi-2024.2.1/parallelio-2.6.6-fisdggccpiiuzlshmernllyvvakay3ms/lib
PNETCDF_PATH := /glade/u/apps/derecho/24.12/spack/opt/spack/parallel-netcdf/1.14.0/cray-mpich/8.1.29/oneapi/2024.2.1/la34
SCC := icx
SCXX := icpx
SFC := ifort
SLIBS := $(SLIBS)  
SUPPORTS_CXX := TRUE

ifeq "$(COMP_NAME)" "mom"
  CPPDEFS := $(CPPDEFS)  -DCESMCOUPLED -Duse_LARGEFILE -DFORTRANUNDERSCORE -DCPRINTEL -DLINUX -DHAVE_GETTID
  FFLAGS :=  $(FC_AUTO_R8)  -O0 -no-fma -g -check uninit -check bounds -check pointers -fpe0 -check noarg_temp_created -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source -qopt-report -march=core-avx2
endif
ifeq "$(COMP_NAME)" "gptl"
  CPPDEFS := $(CPPDEFS)  -DCESMCOUPLED -DFORTRANUNDERSCORE -DCPRINTEL -DLINUX -DHAVE_NANOTIME -DBIT64 -DHAVE_VPRINTF -DHAVE_BACKTRACE -DHAVE_SLASHPROC -DHAVE_COMM_F2C -DHAVE_TIMES -DHAVE_GETTIMEOFDAY -DHAVE_NANOTIME -DBIT64 -DHAVE_VPRINTF -DHAVE_BACKTRACE -DHAVE_SLASHPROC -DHAVE_COMM_F2C -DHAVE_TIMES -DHAVE_GETTIMEOFDAY -DHAVE_GETTID -DHAVE_SLASHPROC
endif
ifeq "$(COMP_NAME)" "mpi-serial"
  CFLAGS :=  -qno-opt-dynamic-align -fp-model precise -std=gnu99 -O0 -no-fma -g -qopt-report -march=core-avx2 -std=c89 
endif
