module camsrfexch

  !-----------------------------------------------------------------------
  ! Module to handle data that is exchanged between the CAM atmosphere
  ! model and the surface models (land, sea-ice, and ocean).
  !-----------------------------------------------------------------------

  use shr_kind_mod,    only: r8 => shr_kind_r8, r4 => shr_kind_r4
  use constituents,    only: pcnst
  use ppgrid,          only: pcols, begchunk, endchunk
  use phys_grid,       only: get_ncols_p, phys_grid_initialized
  use infnan,          only: posinf, assignment(=)
  use cam_abortutils,  only: endrun
  use cam_logfile,     only: iulog
  use srf_field_check, only: active_Sl_ram1, active_Sl_fv, active_Sl_soilw,                &
                             active_Fall_flxdst1, active_Fall_flxvoc, active_Fall_flxfire, &
                             active_Faxa_nhx, active_Faxa_noy



  implicit none
  private

  ! Public interfaces
  public atm2hub_alloc              ! Atmosphere to surface data allocation method
  public hub2atm_alloc              ! Merged hub surface to atmosphere data allocation method
  public atm2hub_deallocate
  public hub2atm_deallocate
  public cam_export
  public get_prec_vars
  ! Public data types
  public cam_out_t                  ! Data from atmosphere
  public cam_in_t                   ! Merged surface data

  !---------------------------------------------------------------------------
  ! This is the data that is sent from the atmosphere to the surface models
  !---------------------------------------------------------------------------

  type cam_out_t
     integer  :: lchnk               ! chunk index
     integer  :: ncol                ! number of columns in chunk
     real(r8) :: tbot(pcols)         ! bot level temperature
     real(r8) :: zbot(pcols)         ! bot level height above surface
     real(r8) :: topo(pcols)         ! surface topographic height (m)
     real(r8) :: ubot(pcols)         ! bot level u wind
     real(r8) :: vbot(pcols)         ! bot level v wind
     real(r8) :: qbot(pcols,pcnst)   ! bot level specific humidity
     real(r8) :: pbot(pcols)         ! bot level pressure
     real(r8) :: rho(pcols)          ! bot level density
     real(r8) :: netsw(pcols)        !
     real(r8) :: flwds(pcols)        !
     real(r8) :: precsc(pcols)       !
     real(r8) :: precsl(pcols)       !
     real(r8) :: precc(pcols)        !
     real(r8) :: precl(pcols)        !
     real(r8) :: hrain(pcols)        ! material enth. flx for liquid precip
     real(r8) :: hsnow(pcols)        ! material enth. flx for frozen precip
     real(r8) :: hevap(pcols)        ! material enth. flx for evaporation
     real(r8) :: soll(pcols)         !
     real(r8) :: sols(pcols)         !
     real(r8) :: solld(pcols)        !
     real(r8) :: solsd(pcols)        !
     real(r8) :: thbot(pcols)        !
     real(r8) :: co2prog(pcols)      ! prognostic co2
     real(r8) :: co2diag(pcols)      ! diagnostic co2
     real(r8) :: ozone(pcols)        ! surface ozone concentration (mole/mole)
     real(r8) :: lightning_flash_freq(pcols) ! cloud-to-ground lightning flash frequency (/min)
     real(r8) :: psl(pcols)
     real(r8) :: bcphiwet(pcols)     ! wet deposition of hydrophilic black carbon
     real(r8) :: bcphidry(pcols)     ! dry deposition of hydrophilic black carbon
     real(r8) :: bcphodry(pcols)     ! dry deposition of hydrophobic black carbon
     real(r8) :: ocphiwet(pcols)     ! wet deposition of hydrophilic organic carbon
     real(r8) :: ocphidry(pcols)     ! dry deposition of hydrophilic organic carbon
     real(r8) :: ocphodry(pcols)     ! dry deposition of hydrophobic organic carbon
     real(r8) :: dstwet1(pcols)      ! wet deposition of dust (bin1)
     real(r8) :: dstdry1(pcols)      ! dry deposition of dust (bin1)
     real(r8) :: dstwet2(pcols)      ! wet deposition of dust (bin2)
     real(r8) :: dstdry2(pcols)      ! dry deposition of dust (bin2)
     real(r8) :: dstwet3(pcols)      ! wet deposition of dust (bin3)
     real(r8) :: dstdry3(pcols)      ! dry deposition of dust (bin3)
     real(r8) :: dstwet4(pcols)      ! wet deposition of dust (bin4)
     real(r8) :: dstdry4(pcols)      ! dry deposition of dust (bin4)
     real(r8), pointer, dimension(:) :: nhx_nitrogen_flx ! nitrogen deposition fluxes (kgN/m2/s)
     real(r8), pointer, dimension(:) :: noy_nitrogen_flx ! nitrogen deposition fluxes (kgN/m2/s)
  end type cam_out_t

  !---------------------------------------------------------------------------
  ! This is the merged state of sea-ice, land and ocean surface parameterizations
  !---------------------------------------------------------------------------

  type cam_in_t
     integer  :: lchnk                   ! chunk index
     integer  :: ncol                    ! number of active columns
     real(r8) :: asdir(pcols)            ! albedo: shortwave, direct
     real(r8) :: asdif(pcols)            ! albedo: shortwave, diffuse
     real(r8) :: aldir(pcols)            ! albedo: longwave, direct
     real(r8) :: aldif(pcols)            ! albedo: longwave, diffuse
     real(r8) :: lwup(pcols)             ! longwave up radiative flux
     real(r8) :: lhf(pcols)              ! latent heat flux
     real(r8) :: shf(pcols)              ! sensible heat flux
     real(r8) :: wsx(pcols)              ! surface u-stress (N)
     real(r8) :: wsy(pcols)              ! surface v-stress (N)
     real(r8) :: tref(pcols)             ! ref height surface air temp
     real(r8) :: qref(pcols)             ! ref height specific humidity
     real(r8) :: u10(pcols)              ! 10m wind speed
     real(r8) :: ugustOut(pcols)         ! gustiness added
     real(r8) :: u10withGusts(pcols)     ! 10m wind speed with gusts added
     real(r8) :: ts(pcols)               ! merged surface temp
     real(r8) :: sst(pcols)              ! sea surface temp
     real(r8) :: snowhland(pcols)        ! snow depth (liquid water equivalent) over land
     real(r8) :: snowhice(pcols)         ! snow depth over ice
     real(r8) :: fco2_lnd(pcols)         ! co2 flux from lnd
     real(r8) :: fco2_ocn(pcols)         ! co2 flux from ocn
     real(r8) :: fdms(pcols)             ! dms flux
     real(r8) :: landfrac(pcols)         ! land area fraction
     real(r8) :: icefrac(pcols)          ! sea-ice areal fraction
     real(r8) :: ocnfrac(pcols)          ! ocean areal fraction
     real(r8) :: cflx(pcols,pcnst)       ! constituent flux (emissions)
     real(r8) :: ustar(pcols)            ! atm/ocn saved version of ustar
     real(r8) :: re(pcols)               ! atm/ocn saved version of re
     real(r8) :: ssq(pcols)              ! atm/ocn saved version of ssq
     real(r8), pointer, dimension(:)   :: ram1  !aerodynamical resistance (s/m) (pcols)
     real(r8), pointer, dimension(:)   :: fv    !friction velocity (m/s) (pcols)
     real(r8), pointer, dimension(:)   :: soilw !volumetric soil water (m3/m3)
     real(r8), pointer, dimension(:,:) :: depvel ! deposition velocities
     real(r8), pointer, dimension(:,:) :: dstflx ! dust fluxes
     real(r8), pointer, dimension(:,:) :: meganflx ! MEGAN fluxes
     real(r8), pointer, dimension(:,:) :: fireflx ! wild fire emissions
     real(r8), pointer, dimension(:)   :: fireztop ! wild fire emissions vert distribution top
  end type cam_in_t

!===============================================================================
CONTAINS
!===============================================================================

  subroutine hub2atm_alloc( cam_in )

    ! Allocate space for the surface to atmosphere data type. And initialize
    ! the values.

    use shr_drydep_mod,  only: n_drydep
    use shr_megan_mod,   only: shr_megan_mechcomps_n
    use shr_fire_emis_mod,only: shr_fire_emis_mechcomps_n

    ! ARGUMENTS:
    type(cam_in_t), pointer ::  cam_in(:)     ! Merged surface state

    ! LOCAL VARIABLES:
    integer :: c        ! chunk index
    integer :: ierror   ! Error code
    character(len=*), parameter :: sub = 'hub2atm_alloc'
    !-----------------------------------------------------------------------

    if ( .not. phys_grid_initialized() ) call endrun(sub//": phys_grid not called yet")
    allocate (cam_in(begchunk:endchunk), stat=ierror)
    if ( ierror /= 0 )then
      write(iulog,*) sub//': Allocation error: ', ierror
      call endrun(sub//': allocation error')
    end if

    do c = begchunk,endchunk
       nullify(cam_in(c)%ram1)
       nullify(cam_in(c)%fv)
       nullify(cam_in(c)%soilw)
       nullify(cam_in(c)%depvel)
       nullify(cam_in(c)%dstflx)
       nullify(cam_in(c)%meganflx)
       nullify(cam_in(c)%fireflx)
       nullify(cam_in(c)%fireztop)
    enddo
    do c = begchunk,endchunk
       if (active_Sl_ram1) then
          allocate (cam_in(c)%ram1(pcols), stat=ierror)
          if ( ierror /= 0 ) call endrun(sub//': allocation error ram1')
       endif
       if (active_Sl_fv) then
          allocate (cam_in(c)%fv(pcols), stat=ierror)
          if ( ierror /= 0 ) call endrun(sub//': allocation error fv')
       endif
       if (active_Sl_soilw) then
          allocate (cam_in(c)%soilw(pcols), stat=ierror)
          if ( ierror /= 0 ) call endrun(sub//': allocation error soilw')
       end if
       if (active_Fall_flxdst1) then
          ! Assume 4 bins from surface model ....
          allocate (cam_in(c)%dstflx(pcols,4), stat=ierror)
          if ( ierror /= 0 ) call endrun(sub//': allocation error dstflx')
       endif
       if (active_Fall_flxvoc .and. shr_megan_mechcomps_n>0) then
          allocate (cam_in(c)%meganflx(pcols,shr_megan_mechcomps_n), stat=ierror)
          if ( ierror /= 0 ) call endrun(sub//': allocation error meganflx')
       endif
    end do

    if (n_drydep>0) then
       do c = begchunk,endchunk
          allocate (cam_in(c)%depvel(pcols,n_drydep), stat=ierror)
          if ( ierror /= 0 ) call endrun(sub//': allocation error depvel')
       end do
    endif

    if (active_Fall_flxfire .and. shr_fire_emis_mechcomps_n>0) then
       do c = begchunk,endchunk
          allocate(cam_in(c)%fireflx(pcols,shr_fire_emis_mechcomps_n), stat=ierror)
          if ( ierror /= 0 ) call endrun(sub//': allocation error fireflx')
          allocate(cam_in(c)%fireztop(pcols), stat=ierror)
          if ( ierror /= 0 ) call endrun(sub//': allocation error fireztop')
       enddo
    endif

    do c = begchunk,endchunk
       cam_in(c)%lchnk = c
       cam_in(c)%ncol  = get_ncols_p(c)
       cam_in(c)%asdir    (:) = 0._r8
       cam_in(c)%asdif    (:) = 0._r8
       cam_in(c)%aldir    (:) = 0._r8
       cam_in(c)%aldif    (:) = 0._r8
       cam_in(c)%lwup     (:) = 0._r8
       cam_in(c)%lhf      (:) = 0._r8
       cam_in(c)%shf      (:) = 0._r8
       cam_in(c)%wsx      (:) = 0._r8
       cam_in(c)%wsy      (:) = 0._r8
       cam_in(c)%tref     (:) = 0._r8
       cam_in(c)%qref     (:) = 0._r8
       cam_in(c)%u10      (:) = 0._r8
       cam_in(c)%ugustOut (:) = 0._r8
       cam_in(c)%u10withGusts (:) = 0._r8
       cam_in(c)%ts       (:) = 0._r8
       cam_in(c)%sst      (:) = 0._r8
       cam_in(c)%snowhland(:) = 0._r8
       cam_in(c)%snowhice (:) = 0._r8
       cam_in(c)%fco2_lnd (:) = 0._r8
       cam_in(c)%fco2_ocn (:) = 0._r8
       cam_in(c)%fdms     (:) = 0._r8
       cam_in(c)%landfrac (:) = posinf
       cam_in(c)%icefrac  (:) = posinf
       cam_in(c)%ocnfrac  (:) = posinf

       if (associated(cam_in(c)%ram1)) &
            cam_in(c)%ram1  (:) = 0.1_r8
       if (associated(cam_in(c)%fv)) &
            cam_in(c)%fv    (:) = 0.1_r8
       if (associated(cam_in(c)%soilw)) &
            cam_in(c)%soilw (:) = 0.0_r8
       if (associated(cam_in(c)%dstflx)) &
            cam_in(c)%dstflx(:,:) = 0.0_r8
       if (associated(cam_in(c)%meganflx)) &
            cam_in(c)%meganflx(:,:) = 0.0_r8

       cam_in(c)%cflx   (:,:) = 0._r8
       cam_in(c)%ustar    (:) = 0._r8
       cam_in(c)%re       (:) = 0._r8
       cam_in(c)%ssq      (:) = 0._r8
       if (n_drydep>0) then
          cam_in(c)%depvel (:,:) = 0._r8
       endif
       if (active_Fall_flxfire .and. shr_fire_emis_mechcomps_n>0) then
          cam_in(c)%fireflx(:,:) = 0._r8
          cam_in(c)%fireztop(:) = 0._r8
       endif
    end do

  end subroutine hub2atm_alloc

  !===============================================================================

  subroutine atm2hub_alloc( cam_out )

    ! Allocate space for the atmosphere to surface data type. And initialize
    ! the values.

    ! ARGUMENTS:
    type(cam_out_t), pointer :: cam_out(:)    ! Atmosphere to surface input

    ! LOCAL VARIABLES:
    integer :: c            ! chunk index
    integer :: ierror       ! Error code
    character(len=*), parameter :: sub = 'atm2hub_alloc'
    !-----------------------------------------------------------------------

    if (.not. phys_grid_initialized()) call endrun(sub//": phys_grid not called yet")
    allocate (cam_out(begchunk:endchunk), stat=ierror)
    if ( ierror /= 0 )then
      write(iulog,*) sub//': Allocation error: ', ierror
      call endrun(sub//': allocation error: cam_out')
    end if

    do c = begchunk,endchunk
       cam_out(c)%lchnk       = c
       cam_out(c)%ncol        = get_ncols_p(c)
       cam_out(c)%tbot(:)     = 0._r8
       cam_out(c)%zbot(:)     = 0._r8
       cam_out(c)%topo(:)     = 0._r8
       cam_out(c)%ubot(:)     = 0._r8
       cam_out(c)%vbot(:)     = 0._r8
       cam_out(c)%qbot(:,:)   = 0._r8
       cam_out(c)%pbot(:)     = 0._r8
       cam_out(c)%rho(:)      = 0._r8
       cam_out(c)%netsw(:)    = 0._r8
       cam_out(c)%flwds(:)    = 0._r8
       cam_out(c)%precsc(:)   = 0._r8
       cam_out(c)%precsl(:)   = 0._r8
       cam_out(c)%precc(:)    = 0._r8
       cam_out(c)%precl(:)    = 0._r8
       cam_out(c)%soll(:)     = 0._r8
       cam_out(c)%sols(:)     = 0._r8
       cam_out(c)%solld(:)    = 0._r8
       cam_out(c)%solsd(:)    = 0._r8
       cam_out(c)%thbot(:)    = 0._r8
       cam_out(c)%co2prog(:)  = 0._r8
       cam_out(c)%co2diag(:)  = 0._r8
       cam_out(c)%ozone(:)    = 0._r8
       cam_out(c)%lightning_flash_freq(:) = 0._r8
       cam_out(c)%psl(:)      = 0._r8
       cam_out(c)%bcphidry(:) = 0._r8
       cam_out(c)%bcphodry(:) = 0._r8
       cam_out(c)%bcphiwet(:) = 0._r8
       cam_out(c)%ocphidry(:) = 0._r8
       cam_out(c)%ocphodry(:) = 0._r8
       cam_out(c)%ocphiwet(:) = 0._r8
       cam_out(c)%dstdry1(:)  = 0._r8
       cam_out(c)%dstwet1(:)  = 0._r8
       cam_out(c)%dstdry2(:)  = 0._r8
       cam_out(c)%dstwet2(:)  = 0._r8
       cam_out(c)%dstdry3(:)  = 0._r8
       cam_out(c)%dstwet3(:)  = 0._r8
       cam_out(c)%dstdry4(:)  = 0._r8
       cam_out(c)%dstwet4(:)  = 0._r8

       nullify(cam_out(c)%nhx_nitrogen_flx)
       allocate (cam_out(c)%nhx_nitrogen_flx(pcols), stat=ierror)
       if ( ierror /= 0 ) call endrun(sub//': allocation error nhx_nitrogen_flx')
       cam_out(c)%nhx_nitrogen_flx(:) = 0._r8

       nullify(cam_out(c)%noy_nitrogen_flx)
       allocate (cam_out(c)%noy_nitrogen_flx(pcols), stat=ierror)
       if ( ierror /= 0 ) call endrun(sub//': allocation error noy_nitrogen_flx')
       cam_out(c)%noy_nitrogen_flx(:) = 0._r8
    end do

  end subroutine atm2hub_alloc

  !===============================================================================

  subroutine atm2hub_deallocate(cam_out)

    type(cam_out_t), pointer :: cam_out(:)    ! Atmosphere to surface input
    !-----------------------------------------------------------------------

    if(associated(cam_out)) then
       deallocate(cam_out)
    end if
    nullify(cam_out)

  end subroutine atm2hub_deallocate

  !===============================================================================

  subroutine hub2atm_deallocate(cam_in)

    type(cam_in_t), pointer :: cam_in(:)    ! Atmosphere to surface input

    integer :: c
    !-----------------------------------------------------------------------

    if(associated(cam_in)) then
       do c=begchunk,endchunk
          if(associated(cam_in(c)%ram1)) then
             deallocate(cam_in(c)%ram1)
             nullify(cam_in(c)%ram1)
          end if
          if(associated(cam_in(c)%fv)) then
             deallocate(cam_in(c)%fv)
             nullify(cam_in(c)%fv)
          end if
          if(associated(cam_in(c)%soilw)) then
             deallocate(cam_in(c)%soilw)
             nullify(cam_in(c)%soilw)
          end if
          if(associated(cam_in(c)%dstflx)) then
             deallocate(cam_in(c)%dstflx)
             nullify(cam_in(c)%dstflx)
          end if
          if(associated(cam_in(c)%meganflx)) then
             deallocate(cam_in(c)%meganflx)
             nullify(cam_in(c)%meganflx)
          end if
          if(associated(cam_in(c)%depvel)) then
             deallocate(cam_in(c)%depvel)
             nullify(cam_in(c)%depvel)
          end if

       enddo

       deallocate(cam_in)
    end if
    nullify(cam_in)

  end subroutine hub2atm_deallocate


!======================================================================

subroutine cam_export(state,cam_in,cam_out,pbuf)

   ! Transfer atmospheric fields into necessary surface data structures

   use physics_types,    only: physics_state
   use ppgrid,           only: pver
   use cam_history,      only: outfld
   use chem_surfvals,    only: chem_surfvals_get
   use co2_cycle,        only: co2_transport, c_i
   use physconst,        only: rair, mwdry, mwco2, gravit, mwo3, cpliq, cpice, cpwv, tmelt
   use constituents,     only: pcnst
   use physics_buffer,   only: pbuf_get_index, pbuf_get_field, physics_buffer_desc, pbuf_set_field
   use rad_constituents, only: rad_cnst_get_gas
   use cam_control_mod,  only: simple_phys
   use air_composition,  only: hliq_idx, hice_idx, fliq_idx, fice_idx
   use air_composition,  only: enthalpy_flux_method, num_enthalpy_vars, enthalpy_flux_method
   implicit none

   ! Input arguments
   type(physics_state),  intent(in) :: state
   type (cam_in_t ),     intent(in)    :: cam_in
   type (cam_out_t),     intent(inout) :: cam_out
   type(physics_buffer_desc), pointer  :: pbuf(:)

   ! Local variables

   integer :: i              ! Longitude index
   integer :: m              ! constituent index
   integer :: lchnk          ! Chunk index
   integer :: ncol
   integer :: psl_idx
   integer :: srf_ozone_idx, lightning_idx
   integer :: enthalpy_prec_bc_idx, enthalpy_prec_ac_idx, enthalpy_evap_idx

   real(r8), pointer :: psl(:)

   real(r8), pointer :: o3_ptr(:,:), srf_o3_ptr(:)
   real(r8), pointer :: lightning_ptr(:)
   !
   ! enthalpy variables (if applicable)
   !
   real(r8), dimension(:,:), pointer            :: enthalpy_prec_ac
   real(r8), dimension(pcols)                   :: fliq_tot, fice_tot
   real(r8), dimension(pcols)                   :: tmp
   real(r8), dimension(pcols,num_enthalpy_vars) :: enthalpy_prec_bc

   character(len=*), parameter :: sub = 'cam_export'
   !-----------------------------------------------------------------------

   lchnk = state%lchnk
   ncol  = state%ncol

   psl_idx = pbuf_get_index('PSL')
   call pbuf_get_field(pbuf, psl_idx, psl)

   if (enthalpy_flux_method>0) then
      enthalpy_prec_bc_idx = pbuf_get_index('ENTHALPY_PREC_BC', errcode=i)
      enthalpy_prec_ac_idx = pbuf_get_index('ENTHALPY_PREC_AC', errcode=i)
      enthalpy_evap_idx    = pbuf_get_index('ENTHALPY_EVAP'   , errcode=i)
      if (enthalpy_prec_bc_idx==0.or.enthalpy_prec_ac_idx==0.or.enthalpy_evap_idx==0) then
         call endrun(sub//": pbufs for enthalpy flux not allocated")
      end if
      call pbuf_get_field(pbuf, enthalpy_prec_ac_idx, enthalpy_prec_ac)
      !
      !------------------------------------------------------------------
      !
      ! compute precipitation fluxes and set associated physics buffers
      !
      !------------------------------------------------------------------
      !
      call get_prec_vars(ncol,pbuf,fliq=fliq_tot,fice=fice_tot,&
           precc_out=cam_out%precc,precl_out=cam_out%precl,&
           precsc_out=cam_out%precsc,precsl_out=cam_out%precsl)
      !
      ! fliq_tot holds liquid precipitation from tphysbc and
      ! tphysac from previous physics time-step: back out fliq_bc
      !
      ! Idem for ice
      !
      enthalpy_prec_bc(:ncol,fice_idx) = fice_tot(:ncol) -enthalpy_prec_ac(:ncol,fice_idx)
      enthalpy_prec_bc(:ncol,fliq_idx) = fliq_tot(:ncol) -enthalpy_prec_ac(:ncol,fliq_idx)
      !
      ! compute precipitation enthalpy fluxes from tphysbc
      !
      select case (enthalpy_flux_method)
      case(1,2,3)
         !
         ! CESM3 development option using cpliq for all species and SST temperature
         !
         enthalpy_prec_bc(:ncol,hice_idx) =  -enthalpy_prec_bc(:ncol,fice_idx)*cpliq*(cam_in%ts(:ncol)-tmelt)
         enthalpy_prec_bc(:ncol,hliq_idx) =  -enthalpy_prec_bc(:ncol,fliq_idx)*cpliq*(cam_in%ts(:ncol)-tmelt)
         !
         ! compute evaporation enthalpy flux
         !
         cam_out%hevap(:ncol) = cam_in%cflx(:ncol,1)*cpliq*(cam_in%ts(:ncol)-tmelt)
         !
         ! Compute enthalpy fluxes for the coupler:
         !
         cam_out%hsnow (:ncol) = enthalpy_prec_bc(:ncol,hice_idx)+enthalpy_prec_ac(:ncol,hice_idx)
         cam_out%hrain (:ncol) = enthalpy_prec_bc(:ncol,hliq_idx)+enthalpy_prec_ac(:ncol,hliq_idx)
         !
         ! ->Change enthalpy flux to sign convention of ocean model and change to liquid reference state
         !
         cam_out%hsnow (:ncol) = -cam_out%hsnow(:ncol)!xxx -fice_tot(:ncol)*tmelt*cpliq
         cam_out%hrain (:ncol) = -cam_out%hrain(:ncol)!xxx -fliq_tot(:ncol)*tmelt*cpliq
         cam_out%hevap(:ncol)  = -cam_out%hevap(:ncol)!xxx +cam_in%cflx(:ncol,1)*tmelt*cpliq
      case DEFAULT
         enthalpy_prec_bc(:ncol,hice_idx) =  -enthalpy_prec_bc(:ncol,fice_idx)*cpice*state%T(:ncol,pver)
         enthalpy_prec_bc(:ncol,hliq_idx) =  -enthalpy_prec_bc(:ncol,fliq_idx)*cpliq*state%T(:ncol,pver)
         !
         ! compute evaporation enthalpy flux
         !
         cam_out%hevap(:ncol) = cam_in%cflx(:ncol,1)*cam_in%ts(:ncol)*cpwv
      end select

      call pbuf_set_field(pbuf, enthalpy_prec_bc_idx, enthalpy_prec_bc)
      call pbuf_set_field(pbuf, enthalpy_evap_idx, -cam_out%hevap)!use sign for atmosphere

      tmp(:ncol) = cam_out%hsnow(:ncol)!*cam_in%ocnfrac(:ncol)
      call outfld("hsnow_liq_ref"  , tmp, pcols   ,lchnk   )!xxx debug
      tmp(:ncol) = cam_out%hrain(:ncol)!*cam_in%ocnfrac(:ncol)
      call outfld("hrain_liq_ref"  ,  tmp, pcols   ,lchnk   )!xxx debug
      tmp(:ncol) = cam_out%hevap(:ncol)!*cam_in%ocnfrac(:ncol)
      call outfld("hevap_liq_ref"  , tmp, pcols   ,lchnk   )!xxx debug
   else
      call get_prec_vars(ncol,pbuf,&
           precc_out=cam_out%precc,precl_out=cam_out%precl,&
           precsc_out=cam_out%precsc,precsl_out=cam_out%precsl)
   end if

   srf_ozone_idx = pbuf_get_index('SRFOZONE', errcode=i)
   lightning_idx = pbuf_get_index('LGHT_FLASH_FREQ', errcode=i)

   do i=1,ncol
      cam_out%tbot(i)  = state%t(i,pver)
      cam_out%thbot(i) = state%t(i,pver) * state%exner(i,pver)
      cam_out%zbot(i)  = state%zm(i,pver)
      cam_out%topo(i)  = state%phis(i) / gravit
      cam_out%ubot(i)  = state%u(i,pver)
      cam_out%vbot(i)  = state%v(i,pver)
      cam_out%pbot(i)  = state%pmid(i,pver)
      cam_out%psl(i)   = psl(i)
      cam_out%rho(i)   = cam_out%pbot(i)/(rair*cam_out%tbot(i))
   end do
   do m = 1, pcnst
     do i = 1, ncol
        cam_out%qbot(i,m) = state%q(i,pver,m)
     end do
   end do

   cam_out%co2diag(:ncol) = chem_surfvals_get('CO2VMR') * 1.0e+6_r8
   if (co2_transport()) then
      do i=1,ncol
         cam_out%co2prog(i) = state%q(i,pver,c_i(4)) * 1.0e+6_r8 *mwdry/mwco2
      end do
   end if

   ! get bottom layer ozone concentrations to export to surface models
   if (srf_ozone_idx > 0) then
      call pbuf_get_field(pbuf, srf_ozone_idx, srf_o3_ptr)
      cam_out%ozone(:ncol) = srf_o3_ptr(:ncol)
   else if (.not.simple_phys) then
      call rad_cnst_get_gas(0, 'O3', state, pbuf, o3_ptr)
      cam_out%ozone(:ncol) = o3_ptr(:ncol,pver) * mwdry/mwo3 ! mole/mole
   endif

   ! get cloud to ground lightning flash freq (/min) to export to surface models
   if (lightning_idx>0) then
      call pbuf_get_field(pbuf, lightning_idx, lightning_ptr)
      cam_out%lightning_flash_freq(:ncol) = lightning_ptr(:ncol)
   end if
end subroutine cam_export
!
! Precipation and snow rates from shallow convection, deep convection and stratiform processes.
! Compute total convective and stratiform precipitation and snow rates
!
subroutine get_prec_vars(ncol,pbuf,fliq,fice, precc_out,precl_out,precsc_out,precsl_out)
     use ppgrid, only: pcols
     use physics_buffer,   only: pbuf_get_index, pbuf_get_field, physics_buffer_desc

     integer, intent(in) :: ncol
     type(physics_buffer_desc), pointer         :: pbuf(:)
     real(r8), dimension(pcols) , optional, intent(out):: fliq!rain flux in SI units
     real(r8), dimension(pcols) , optional, intent(out):: fice!snow flux in SI units

     real(r8), dimension(pcols), optional, intent(out):: precc_out !total precipitation from convection
     real(r8), dimension(pcols), optional, intent(out):: precl_out !total large scale precipitation
     real(r8), dimension(pcols), optional, intent(out):: precsc_out!frozen precipitation from convection
     real(r8), dimension(pcols), optional, intent(out):: precsl_out!frozen large scale precipitation

     integer :: i

     real(r8), pointer :: prec_dp(:)                 !total precipitation from from deep convection
     real(r8), pointer :: snow_dp(:)                 !frozen precipitation from deep convection
     real(r8), pointer :: prec_sh(:)                 !total precipitation from shallow convection
     real(r8), pointer :: snow_sh(:)                 !frozen precipitation from from shallow convection
     real(r8), pointer :: prec_sed(:)                !total precipitation from cloud sedimentation
     real(r8), pointer :: snow_sed(:)                !frozen precipitation from sedimentation
     real(r8), pointer :: prec_pcw(:)                !total precipitation from from microphysics
     real(r8), pointer :: snow_pcw(:)                !frozen precipitation from from microphysics

     real(r8), dimension(pcols):: precc, precl, precsc, precsl
     integer :: prec_dp_idx, snow_dp_idx, prec_sh_idx, snow_sh_idx
     integer :: prec_sed_idx,snow_sed_idx,prec_pcw_idx,snow_pcw_idx
     !
     ! get fields from pbuf
     !
     prec_dp_idx = pbuf_get_index('PREC_DP', errcode=i)
     snow_dp_idx = pbuf_get_index('SNOW_DP', errcode=i)
     prec_sh_idx = pbuf_get_index('PREC_SH', errcode=i)
     snow_sh_idx = pbuf_get_index('SNOW_SH', errcode=i)
     prec_sed_idx = pbuf_get_index('PREC_SED', errcode=i)
     snow_sed_idx = pbuf_get_index('SNOW_SED', errcode=i)
     prec_pcw_idx = pbuf_get_index('PREC_PCW', errcode=i)
     snow_pcw_idx = pbuf_get_index('SNOW_PCW', errcode=i)

     if (prec_dp_idx > 0) then
        call pbuf_get_field(pbuf, prec_dp_idx, prec_dp)
     end if
     if (snow_dp_idx > 0) then
        call pbuf_get_field(pbuf, snow_dp_idx, snow_dp)
     end if
     if (prec_sh_idx > 0) then
        call pbuf_get_field(pbuf, prec_sh_idx, prec_sh)
     end if
     if (snow_sh_idx > 0) then
        call pbuf_get_field(pbuf, snow_sh_idx, snow_sh)
     end if
     if (prec_sed_idx > 0) then
        call pbuf_get_field(pbuf, prec_sed_idx, prec_sed)
     end if
     if (snow_sed_idx > 0) then
        call pbuf_get_field(pbuf, snow_sed_idx, snow_sed)
     end if
     if (prec_pcw_idx > 0) then
        call pbuf_get_field(pbuf, prec_pcw_idx, prec_pcw)
     end if
     if (snow_pcw_idx > 0) then
        call pbuf_get_field(pbuf, snow_pcw_idx, snow_pcw)
     end if

     precc  = 0._r8
     precl  = 0._r8
     precsc = 0._r8
     precsl = 0._r8
     if (prec_dp_idx > 0) then
        precc(:ncol) = precc(:ncol) + prec_dp(:ncol)
     end if
     if (prec_sh_idx > 0) then
        precc(:ncol)  = precc(:ncol)  + prec_sh(:ncol)
     end if
     if (prec_sed_idx > 0) then
        precl(:ncol) = precl(1:ncol) + prec_sed(:ncol)
     end if
     if (prec_pcw_idx > 0) then
        precl(:ncol)  = precl(1:ncol) + prec_pcw(:ncol)
     end if
     if (snow_dp_idx > 0) then
        precsc(:ncol) = precsc(:ncol) + snow_dp(:ncol)
     end if
     if (snow_sh_idx > 0) then
        precsc(:ncol) = precsc(:ncol) + snow_sh(:ncol)
     end if
     if (snow_sed_idx > 0) then
        precsl(:ncol) = precsl(:ncol) + snow_sed(:ncol)
     end if
     if (snow_pcw_idx > 0) then
        precsl(:ncol)= precsl(:ncol) + snow_pcw(:ncol)
     end if

     do i=1,ncol
        precc(i)  = MAX(precc(i), 0.0_r8)
        precl(i)  = MAX(precl(i), 0.0_r8)
        precsc(i) = MAX(precsc(i),0.0_r8)
        precsl(i) = MAX(precsl(i),0.0_r8)
        if (precsc(i).gt.precc(i)) precsc(i)=precc(i)
        if (precsl(i).gt.precl(i)) precsl(i)=precl(i)
     end do
     if (present(precc_out )) precc_out (:ncol) = precc (:ncol)
     if (present(precl_out )) precl_out (:ncol) = precl (:ncol)
     if (present(precsc_out)) precsc_out(:ncol) = precsc(:ncol)
     if (present(precsl_out)) precsl_out(:ncol) = precsl(:ncol)

     if (present(fice)) fice(:ncol) = 1000.0_r8*(precsc(:ncol)+precsl(:ncol))                           !snow flux
     if (present(fliq)) fliq(:ncol) = 1000.0_r8*(precc (:ncol)-precsc(:ncol)+precl(:ncol)-precsl(:ncol))!rain flux
   end subroutine get_prec_vars

end module camsrfexch
