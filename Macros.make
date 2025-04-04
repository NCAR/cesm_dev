
# This file is auto-generated, do not edit. If you want to change
# sharedlib flags, you can edit the cmake_macros in this case. You
# can change flags for specific sharedlibs only by checking COMP_NAME.

CFLAGS :=  -qno-opt-dynamic-align -fp-model precise -std=gnu99 -O2 -debug minimal -no-fma -qopt-report -march=core-avx2
CMAKE_OPTS := -DCMAKE_SYSTEM_NAME=Catamount
CONFIG_ARGS := --host=cray
CPPDEFS := $(CPPDEFS)  -DCESMCOUPLED -DFORTRANUNDERSCORE -DCPRINTEL -DLINUX -DHAVE_GETTID
CXX_LDFLAGS :=  -cxxlib
CXX_LINKER := FORTRAN
FC_AUTO_R8 := -r8
FFLAGS :=  -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source -O2 -debug minimal -no-fma -qopt-report -march=core-avx2
FFLAGS_NOOPT := -O0
FIXEDFLAGS := -fixed
FREEFLAGS := -free
MACRO_FILE := 
MPICC := cc
MPICXX := CC
MPIFC := ftn
MPI_SERIAL_PATH := 
NETCDF_PATH := /glade/u/apps/derecho/23.09/spack/opt/spack/netcdf/4.9.2/cray-mpich/8.1.27/oneapi/2023.2.1/wplx
PIO_FILESYSTEM_HINTS := lustre
PIO_INCDIR := /glade/u/apps/derecho/23.09/spack/opt/spack/parallelio/2.6.2/cray-mpich/8.1.27/oneapi/2023.2.1/zyhu/include
PIO_LIBDIR := /glade/u/apps/derecho/23.09/spack/opt/spack/parallelio/2.6.2/cray-mpich/8.1.27/oneapi/2023.2.1/zyhu/lib
PNETCDF_PATH := /glade/u/apps/derecho/23.09/spack/opt/spack/parallel-netcdf/1.12.3/cray-mpich/8.1.27/oneapi/2023.2.1/2qqp
SCC := icx
SCXX := CC
SFC := ifort
SLIBS := $(SLIBS)  
SUPPORTS_CXX := TRUE

ifeq "$(COMP_NAME)" "mom"
  CPPDEFS := $(CPPDEFS)  -DCESMCOUPLED -Duse_LARGEFILE -DFORTRANUNDERSCORE -DCPRINTEL -DLINUX -DHAVE_GETTID
  FFLAGS :=  $(FC_AUTO_R8)  -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source -O2 -debug minimal -no-fma -qopt-report -march=core-avx2
endif
ifeq "$(COMP_NAME)" "gptl"
  CPPDEFS := $(CPPDEFS)  -DCESMCOUPLED -DFORTRANUNDERSCORE -DCPRINTEL -DLINUX -DHAVE_NANOTIME -DBIT64 -DHAVE_VPRINTF -DHAVE_BACKTRACE -DHAVE_SLASHPROC -DHAVE_COMM_F2C -DHAVE_TIMES -DHAVE_GETTIMEOFDAY -DHAVE_NANOTIME -DBIT64 -DHAVE_VPRINTF -DHAVE_BACKTRACE -DHAVE_SLASHPROC -DHAVE_COMM_F2C -DHAVE_TIMES -DHAVE_GETTIMEOFDAY -DHAVE_GETTID -DHAVE_SLASHPROC
endif
ifeq "$(COMP_NAME)" "mpi-serial"
  CFLAGS :=  -qno-opt-dynamic-align -fp-model precise -std=gnu99 -O2 -debug minimal -no-fma -qopt-report -march=core-avx2 -std=c89 
endif
