
module advance_windm_edsclrm_module

  implicit none

  private ! Set Default Scope

  public :: advance_windm_edsclrm

  private :: windm_edsclrm_solve, &
    compute_uv_tndcy,  &
    windm_edsclrm_lhs, &
    windm_edsclrm_rhs
    

  ! Private named constants to avoid string comparisons
  integer, parameter, private :: &
    windm_edsclrm_um = 1, &     ! Named constant to handle um solves
    windm_edsclrm_vm = 2, &     ! Named constant to handle vm solves
    windm_edsclrm_scalar = 3, & ! Named constant to handle scalar solves
    clip_upwp = 10, &           ! Named constant for upwp clipping
                                ! NOTE: This must be the same as the clip_upwp
                                ! declared in clip_explicit!
    clip_vpwp = 11              ! Named constant for vpwp clipping
                                ! NOTE: This must be the same as the clip_vpwp
                                ! declared in clip_explicit!

  contains

  !=============================================================================
  subroutine advance_windm_edsclrm( nz, ngrdcol, edsclr_dim, gr, dt, &
                                    wm_zt, Km_zm, Kmh_zm, &
                                    ug, vg, um_ref, vm_ref, &
                                    wp2, up2, vp2, um_forcing, vm_forcing, &
                                    edsclrm_forcing, &
                                    rho_ds_zm, invrs_rho_ds_zt, &
                                    fcor, l_implemented, &
                                    nu_vert_res_dep, &
                                    tridiag_solve_method, &
                                    l_predict_upwp_vpwp, &
                                    l_upwind_xm_ma, &
                                    l_uv_nudge, &
                                    l_tke_aniso, &
                                    l_lmm_stepping, &
                                    l_linearize_pbl_winds, &
                                    order_xp2_xpyp, order_wp2_wp3, order_windm, &
                                    stats_metadata, &
                                    stats_zt, stats_zm, stats_sfc, & 
                                    um, vm, edsclrm, &
                                    upwp, vpwp, wpedsclrp, &
                                    um_pert, vm_pert, upwp_pert, vpwp_pert )

    ! Description:
    ! Solves for both mean horizontal wind components, um and vm, and for the
    ! eddy-scalars (passive scalars that don't use the high-order closure).

    ! Uses the LAPACK tridiagonal solver subroutine with 2 + # of scalar(s)
    ! back substitutions (since the left hand side matrix is the same for all
    ! input variables).

    ! References:
    ! Eqn. 8 & 9 on p. 3545 of
    ! ``A PDF-Based Model for Boundary Layer Clouds. Part I:
    ! Method and Model Description'' Golaz, et al. (2002)
    ! JAS, Vol. 59, pp. 3540--3551.
    !-----------------------------------------------------------------------

    use grid_class, only:  &
        grid, &  ! Type
        zm2zt

    use parameters_model, only:  &
        ts_nudge ! Variable(s)

    use parameters_tunable, only: &
        nu_vertical_res_dep    ! Type(s)

    use clubb_precision, only:  &
        core_rknd ! Variable(s)

    use stats_type_utilities, only: &
        stat_begin_update, & ! Subroutines
        stat_end_update, &
        stat_update_var

    use stats_variables, only: &
        stats_metadata_type

    use clip_explicit, only:  &
        clip_covar  ! Procedure(s)

    use error_code, only: &
        clubb_at_least_debug_level,  & ! Procedure
        err_code,                    & ! Error Indicator
        clubb_fatal_error              ! Constant

    use constants_clubb, only:  &
        one_half, & ! Constant(s)
        zero,     &
        fstderr,  &
        eps

    use sponge_layer_damping, only: &
        uv_sponge_damp_settings, &
        uv_sponge_damp_profile, &
        sponge_damp_xm     ! Procedure(s)

    use stats_type, only: stats ! Type

    use diffusion, only:  & 
        diffusion_zt_lhs   ! Procedure(s)

    use mean_adv, only: & 
        term_ma_zt_lhs    ! Procedures
        
    use model_flags, only: &
        l_upwind_Kh_dp_term
        
    use advance_helper_module, only: &
        calc_xpwp

    implicit none

    ! ------------------------ Input Variables ------------------------
    integer, intent(in) :: &
      nz, &
      ngrdcol, &
      edsclr_dim

    type (grid), target, intent(in) :: &
      gr
  
    real( kind = core_rknd ), intent(in) ::  &
      dt                 ! Model timestep                             [s]

    real( kind = core_rknd ), dimension(ngrdcol,nz), intent(in) ::  &
      wm_zt,           & ! w wind component on thermodynamic levels    [m/s]
      Km_zm,           & ! Eddy diffusivity of winds on momentum levs. [m^2/s]
      Kmh_zm,          & ! Eddy diffusivity of themo on momentum levs. [m^s/s]
      ug,              & ! u (west-to-east) geostrophic wind comp.     [m/s]
      vg,              & ! v (south-to-north) geostrophic wind comp.   [m/s]
      um_ref,          & ! Reference u wind component for nudging      [m/s]
      vm_ref,          & ! Reference v wind component for nudging      [m/s]
      wp2,             & ! w'^2 (momentum levels)                      [m^2/s^2]
      up2,             & ! u'^2 (momentum levels)                      [m^2/s^2]
      vp2,             & ! v'^2 (momentum levels)                      [m^2/s^2]
      um_forcing,      & ! u forcing                                   [m/s/s]
      vm_forcing,      & ! v forcing                                   [m/s/s]
      rho_ds_zm,       & ! Dry, static density on momentum levels      [kg/m^3]
      invrs_rho_ds_zt    ! Inv. dry, static density at thermo. levels  [m^3/kg]

    real( kind = core_rknd ), dimension(ngrdcol,nz,edsclr_dim), intent(in) ::  &
      edsclrm_forcing  ! Eddy scalar large-scale forcing        [{units vary}/s]

    real( kind = core_rknd ), dimension(ngrdcol), intent(in) ::  &
      fcor           ! Coriolis parameter                            [s^-1]

    logical, intent(in) ::  &
      l_implemented  ! Flag for CLUBB being implemented in a larger model.

    type(nu_vertical_res_dep), intent(in) :: &
      nu_vert_res_dep    ! Vertical resolution dependent nu values

    integer, intent(in) :: &
      tridiag_solve_method  ! Specifier for method to solve tridiagonal systems

    logical, intent(in) :: &
      l_predict_upwp_vpwp,   & ! Flag to predict <u'w'> and <v'w'> along with <u> and <v> alongside
                               ! the advancement of <rt>, <w'rt'>, <thl>, <wpthlp>, <sclr>, and
                               ! <w'sclr'> in subroutine advance_xm_wpxp.  Otherwise, <u'w'> and
                               ! <v'w'> are still approximated by eddy diffusivity when <u> and <v>
                               ! are advanced in subroutine advance_windm_edsclrm.
      l_upwind_xm_ma,        & ! This flag determines whether we want to use an upwind differencing
                               ! approximation rather than a centered differencing for turbulent or
                               ! mean advection terms. It affects rtm, thlm, sclrm, um and vm.
      l_uv_nudge,            & ! For wind speed nudging
      l_tke_aniso,           & ! For anisotropic turbulent kinetic energy, i.e. TKE = 1/2
                               ! (u'^2 + v'^2 + w'^2)
      l_lmm_stepping,        & ! Apply Linear Multistep Method (LMM) Stepping
      l_linearize_pbl_winds    ! Flag (used by E3SM) to linearize PBL winds

    integer, intent(in) :: &
      order_xp2_xpyp, &
      order_wp2_wp3, &
      order_windm

    type (stats_metadata_type), intent(in) :: &
      stats_metadata

    ! ------------------------ Input/Output Variables ------------------------
    type (stats), dimension(ngrdcol), target, intent(inout) :: &
      stats_zt, &
      stats_zm, &
      stats_sfc
      
    real( kind = core_rknd ), dimension(ngrdcol,nz), intent(inout) ::  &
      um,   & ! Mean u (west-to-east) wind component         [m/s]
      vm,   & ! Mean v (south-to-north) wind component       [m/s]
      upwp, & ! <u'w'> (momentum levels)                     [m^2/s^2]
      vpwp    ! <v'w'> (momentum levels)                     [m^2/s^2]

    ! Input/Output Variable for eddy-scalars
    real( kind = core_rknd ), dimension(ngrdcol,nz,edsclr_dim), intent(inout) ::  &
      edsclrm        ! Mean eddy scalar quantity             [units vary]

    ! Output Variable for eddy-scalars
    real( kind = core_rknd ), dimension(ngrdcol,nz,edsclr_dim), intent(inout) ::  &
      wpedsclrp      ! w'edsclr' (momentum levels)           [m/s {units vary}]

    ! Variables used to track perturbed version of winds.
    real( kind = core_rknd ), dimension(ngrdcol,nz), intent(inout) :: &
      um_pert,   & ! perturbed <u>    [m/s]
      vm_pert,   & ! perturbed <v>    [m/s]
      upwp_pert, & ! perturbed <u'w'> [m^2/s^2]
      vpwp_pert    ! perturbed <v'w'> [m^2/s^2]

    ! ------------------------ Local Variables ------------------------
    real( kind = core_rknd ), dimension(ngrdcol,nz) ::  &
      um_old, & ! Saved value of mean u (west-to-east) wind component    [m/s]
      vm_old    ! Saved value of Mean v (south-to-north) wind component  [m/s]

    real( kind = core_rknd ), dimension(ngrdcol,nz,edsclr_dim) ::  &
      edsclrm_old    ! Saved value of mean eddy scalar quantity   [units vary]

    real( kind = core_rknd ), dimension(ngrdcol,nz) ::  &
      um_tndcy,    & ! u wind component tendency                    [m/s^2]
      vm_tndcy       ! v wind component tendency                    [m/s^2]

    real( kind = core_rknd ), dimension(ngrdcol,nz) ::  &
      upwp_chnge,  & ! Net change of u'w' due to clipping           [m^2/s^2]
      vpwp_chnge     ! Net change of v'w' due to clipping           [m^2/s^2]

    real( kind = core_rknd ), dimension(3,ngrdcol,nz) :: &
      lhs, & ! The implicit part of the tridiagonal matrix             [units vary]
!+++arh
      lhs_scaled ! The implicit part of the tridiagonal matrix             [units vary]

    real( kind = core_rknd ), dimension(ngrdcol,nz,max(2,edsclr_dim)) :: &
      rhs,     &! The explicit part of the tridiagonal matrix       [units vary]
      solution, &  ! The solution to the tridiagonal matrix            [units vary]
!+++arh
      rhs_scaled,     &! The explicit part of the tridiagonal matrix       [units vary]
      solution_scaled  ! The solution to the tridiagonal matrix            [units vary]

    real( kind = core_rknd ), dimension(ngrdcol,nz) :: &
      wind_speed,      & ! wind speed; sqrt(u^2 + v^2)              [m/s]
      wind_speed_pert    ! perturbed wind speed; sprt(u^2 + v^2)    [m/s]

    real( kind = core_rknd ), dimension(ngrdcol) :: &
      u_star_sqd,      & ! Surface friction velocity, u_star, squared      [m/s]
      u_star_sqd_pert    ! perturbed u_star, squared                       [m/s]

    logical :: &
      l_imp_sfc_momentum_flux  ! Flag for implicit momentum surface fluxes.

    integer :: nrhs  ! Number of right hand side terms

    integer :: i, k, edsclr, j  ! Array index

    logical :: l_first_clip_ts, l_last_clip_ts ! flags for clip_covar
    
    real( kind = core_rknd ), dimension(ngrdcol) :: &
      nu_zero
      
    real( kind = core_rknd ), dimension(3,ngrdcol,nz) :: &
      lhs_diff, & ! LHS diffustion terms
!+++arh
      lhs_diff_scaled, & ! LHS diffustion terms
      lhs_ma_zt   ! LHS mean advection terms

!+++arh/hannay
    real( kind = core_rknd ) :: scale_fac = 0.5_core_rknd

    real( kind = core_rknd ), dimension(ngrdcol,nz) ::  &
      Km_zt,          & ! Eddy diffusivity of winds on momentum levs. [m^2/s]
      Kmh_zt,         & ! Eddy diffusivity of themo on momentum levs. [m^s/s]
      Km_zm_p_nu10,   & ! Km_zm plus nu_vert_res_dep%nu10
!+++arh
      Km_zm_p_nu10_scaled,   & ! Km_zm plus nu_vert_res_dep%nu10
      xpwp              ! x'w' for arbitrary x
      
    integer, parameter :: &
      kp1_tdiag = 1, & ! Thermodynamic superdiagonal index.
      k_tdiag   = 2, & ! Thermodynamic main diagonal index.
      km1_tdiag = 3    ! Thermodynamic subdiagonal index.

    ! Whether perturbed winds are being solved.
    logical :: l_perturbed_wind

    real( kind = core_rknd ), dimension(nz) ::  &
      tmp_in

    ! ------------------------ Begin Code ------------------------

    !$acc enter data create( um_old, vm_old, um_tndcy, vm_tndcy, &
    !$acc                    upwp_chnge, vpwp_chnge, lhs, rhs, solution, wind_speed, &
    !$acc                    wind_speed_pert, u_star_sqd, u_star_sqd_pert, &
    !$acc                    nu_zero, lhs_diff, lhs_ma_zt, Km_zt, Kmh_zt, &
    !$acc                    Km_zm_p_nu10, xpwp )

    !$acc enter data if( edsclr_dim > 0) create( edsclrm_old )

    !$acc parallel loop gang vector default(present)
    do i = 1, ngrdcol
      nu_zero(i) = zero
    end do
    !$acc end parallel loop
    
    !$acc parallel loop gang vector collapse(2) default(present)
    do k = 1, nz
      do i = 1, ngrdcol
        Km_zm_p_nu10(i,k) = Km_zm(i,k) + nu_vert_res_dep%nu10(i)
!+++arh
        Km_zm_p_nu10_scaled(i,k) = (scale_fac*Km_zm(i,k)) + nu_vert_res_dep%nu10(i)
      end do
    end do
    !$acc end parallel loop

    l_perturbed_wind = ( .not. l_predict_upwp_vpwp ) .and. l_linearize_pbl_winds
    
    if ( .not. l_implemented ) then
      call term_ma_zt_lhs( nz, ngrdcol, wm_zt, gr%weights_zt2zm, & ! intent(in)
                           gr%invrs_dzt, gr%invrs_dzm,    & ! intent(in)
                           l_upwind_xm_ma,                          & ! intent(in)
                           lhs_ma_zt )                         ! intent(out)
    else
      !$acc parallel loop gang vector collapse(3) default(present)
      do k = 1, nz
        do i = 1, ngrdcol
          do j = 1, 3
            lhs_ma_zt(j,i,k) = zero
          end do
        end do
      end do
      !$acc end parallel loop
    end if

    if ( .not. l_predict_upwp_vpwp ) then
      
      Km_zt(:,:) = zm2zt( nz, ngrdcol, gr, Km_zm(:,:), zero )

      ! Calculate diffusion terms
      call diffusion_zt_lhs( nz, ngrdcol, gr, Km_zm, Km_zt, nu_vert_res_dep%nu10, & ! In
                             invrs_rho_ds_zt, rho_ds_zm,                          & ! In
                             lhs_diff )                                             ! Out
      
      ! The lower boundary condition needs to be applied here at level 2.
      if ( .not. l_upwind_Kh_dp_term ) then 
        !$acc parallel loop gang vector default(present)
        do i = 1, ngrdcol
          ! Thermodynamic superdiagonal: [ x xm(k+1,<t+1>) ]
          lhs_diff(kp1_tdiag,i,2) = - gr%invrs_dzt(i,2) * invrs_rho_ds_zt(i,2) &
                                    * ( Km_zm(i,2) + nu_vert_res_dep%nu10(i) ) &
                                      * rho_ds_zm(i,2) * gr%invrs_dzm(i,2)

          ! Thermodynamic main diagonal: [ x xm(k,<t+1>) ]
          lhs_diff(k_tdiag,i,2) = + gr%invrs_dzt(i,2) * invrs_rho_ds_zt(i,2) &
                                  * ( Km_zm(i,2) + nu_vert_res_dep%nu10(i) ) &
                                    * rho_ds_zm(i,2) * gr%invrs_dzm(i,2)

          ! Thermodynamic subdiagonal: [ x xm(k-1,<t+1>) ]
          lhs_diff(km1_tdiag,i,2) = zero
        end do
        !$acc end parallel loop
      else
        !$acc parallel loop gang vector default(present)
        do i = 1, ngrdcol
          ! Thermodynamic superdiagonal: [ x xm(k+1,<t+1>) ]
          lhs_diff(kp1_tdiag,i,2) = - gr%invrs_dzt(i,2) &
                                      * ( Km_zt(i,2) + nu_vert_res_dep%nu10(i) ) &
                                        * gr%invrs_dzm(i,2)

          ! Thermodynamic main diagonal: [ x xm(k,<t+1>) ]
          lhs_diff(k_tdiag,i,2) = + gr%invrs_dzt(i,2) &
                                    * ( Km_zt(i,2) + nu_vert_res_dep%nu10(i) ) &
                                      * gr%invrs_dzm(i,2)

          ! Thermodynamic subdiagonal: [ x xm(k-1,<t+1>) ]
          lhs_diff(km1_tdiag,i,2) = zero
        end do
        !$acc end parallel loop
      end if

      if ( l_lmm_stepping ) then
        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 1, nz
          do i = 1, ngrdcol
            um_old(i,k) = um(i,k)
            vm_old(i,k) = vm(i,k)
          end do
        end do
        !$acc end parallel loop
      end if ! l_lmm_stepping

      !----------------------------------------------------------------
      ! Prepare tridiagonal system for horizontal winds, um and vm
      !----------------------------------------------------------------

      ! Compute Coriolis, geostrophic, and other prescribed wind forcings for um.
      call compute_uv_tndcy( nz, ngrdcol, windm_edsclrm_um, & ! intent(in)
                             fcor, vm, vg,                  & ! intent(in)
                             um_forcing, l_implemented,     & ! intent(in)
                             stats_metadata,                & ! intent(in)
                             stats_zt,                      & ! intent(inout)
                             um_tndcy )                       ! intent(out)

      ! Compute Coriolis, geostrophic, and other prescribed wind forcings for vm.
      call compute_uv_tndcy( nz, ngrdcol, windm_edsclrm_vm, & ! intent(in)
                             fcor, um, ug,                  & ! intent(in)
                             vm_forcing, l_implemented,     & ! intent(in)
                             stats_metadata,                & ! intent(in)
                             stats_zt,                      & ! intent(inout) 
                             vm_tndcy )                       ! intent(out)

      ! Momentum surface fluxes, u'w'|_sfc and v'w'|_sfc, are applied through
      ! an implicit method, such that:
      !    x'w'|_sfc = - ( u_star(t)^2 / wind_speed(t) ) * xm(t+1).
      l_imp_sfc_momentum_flux = .true.

      ! Compute wind speed (use threshold "eps" to prevent divide-by-zero
      ! error).
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 1, nz
        do i = 1, ngrdcol
          wind_speed(i,k) = max( sqrt( um(i,k)**2 + vm(i,k)**2 ), eps )
        end do
      end do
      !$acc end parallel loop

      ! Compute u_star_sqd according to the definition of u_star.
      !$acc parallel loop gang vector default(present)
      do i = 1, ngrdcol
        u_star_sqd(i) = sqrt( upwp(i,1)**2 + vpwp(i,1)**2 )
      end do
      !$acc end parallel loop

      ! Compute the explicit portion of the um equation.
      ! Build the right-hand side vector.
      call windm_edsclrm_rhs( nz, ngrdcol, gr, windm_edsclrm_um, dt,  & ! intent(in)
                              lhs_diff, um, um_tndcy,                 & ! intent(in)
                              rho_ds_zm, invrs_rho_ds_zt,             & ! intent(in)
                              l_imp_sfc_momentum_flux, upwp(:,1),     & ! intent(in)
                              stats_metadata,                         & ! intent(in)
                              stats_zt,                               & ! intent(inout)
                              rhs(:,:,windm_edsclrm_um) )               ! intent(out)

      ! Compute the explicit portion of the vm equation.
      ! Build the right-hand side vector.
      call windm_edsclrm_rhs( nz, ngrdcol, gr, windm_edsclrm_vm, dt,  & ! intent(in)
                              lhs_diff, vm, vm_tndcy,                 & ! intent(in)
                              rho_ds_zm, invrs_rho_ds_zt,             & ! intent(in)
                              l_imp_sfc_momentum_flux, vpwp(:,1),     & ! intent(in)
                              stats_metadata,                         & ! intent(in)
                              stats_zt,                               & ! intent(inout)
                              rhs(:,:,windm_edsclrm_vm) )               ! intent(out)

      ! Store momentum flux (explicit component)

      ! The surface flux, x'w'(1) = x'w'|_sfc, is set elsewhere in the model.
      ! upwp(1) = upwp_sfc
      ! vpwp(1) = vpwp_sfc
      
      call calc_xpwp( nz, ngrdcol, gr, &
                      Km_zm_p_nu10, um, &
                      xpwp )

      ! Solve for x'w' at all intermediate model levels.
      ! A Crank-Nicholson timestep is used.
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          upwp(i,k) = -one_half * xpwp(i,k)
        end do
      end do
      !$acc end parallel loop
      
      call calc_xpwp( nz, ngrdcol, gr, &
                      Km_zm_p_nu10, vm, &
                      xpwp )
      
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          vpwp(i,k) = -one_half * xpwp(i,k)
        end do
      end do
      !$acc end parallel loop

      ! A zero-flux boundary condition at the top of the model, d(xm)/dz = 0,
      ! means that x'w' at the top model level is 0,
      ! since x'w' = - K_zm * d(xm)/dz.
      !$acc parallel loop gang vector default(present)
      do i = 1, ngrdcol
        upwp(i,nz) = zero
        vpwp(i,nz) = zero
      end do
      !$acc end parallel loop
      
      ! Compute the implicit portion of the um and vm equations.
      ! Build the left-hand side matrix.
      call windm_edsclrm_lhs( nz, ngrdcol, gr, dt,                    & ! intent(in)
                              lhs_ma_zt, lhs_diff,                    & ! intent(in)
                              wind_speed, u_star_sqd,                 & ! intent(in)
                              rho_ds_zm, invrs_rho_ds_zt,             & ! intent(in)
                              l_implemented, l_imp_sfc_momentum_flux, & ! intent(in)
                              lhs )                                     ! intent(out)

      ! Decompose and back substitute for um and vm
      nrhs = 2
      call windm_edsclrm_solve( nz, ngrdcol, gr, nrhs, stats_metadata%iwindm_matrix_condt_num, & ! intent(in)
                                tridiag_solve_method,                           & ! intent(in)
                                stats_metadata,                                 & ! intent(in)
                                stats_sfc, &                                      ! intent(inout)
                                lhs, rhs, &                                       ! intent(inout)
                                solution )                                        ! intent(out)

      ! Check for singular matrices and bad LAPACK arguments
      if ( clubb_at_least_debug_level( 0 ) ) then
        if ( err_code == clubb_fatal_error ) then
          write(fstderr,*) "Fatal error solving for um/vm"
          return
        end if
      end if

      !----------------------------------------------------------------
      ! Update zonal (west-to-east) component of mean wind, um
      !----------------------------------------------------------------
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 1, nz
        do i = 1, ngrdcol
          um(i,k) = solution(i,k,windm_edsclrm_um)
        end do
      end do
      !$acc end parallel loop

      !----------------------------------------------------------------
      ! Update meridional (south-to-north) component of mean wind, vm
      !----------------------------------------------------------------
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 1, nz
        do i = 1, ngrdcol
          vm(i,k) = solution(i,k,windm_edsclrm_vm)
        end do
      end do
      !$acc end parallel loop

      if ( stats_metadata%l_stats_samp ) then

        !$acc update host( um, lhs_diff, lhs_ma_zt, invrs_rho_ds_zt, u_star_sqd, &
        !$acc              rho_ds_zm, wind_speed, vm )

        do i = 1, ngrdcol
          ! Implicit contributions to um and vm
          call windm_edsclrm_implicit_stats( nz, windm_edsclrm_um, um(i,:),       & ! intent(in)
                                             gr%invrs_dzt(i,:),                   & ! intent(in)
                                             lhs_diff(:,i,:), lhs_ma_zt(:,i,:),   & ! intent(in)
                                             invrs_rho_ds_zt(i,:), u_star_sqd(i), & ! intent(in)
                                             rho_ds_zm(i,:), wind_speed(i,:),     & ! intent(in)
                                             l_imp_sfc_momentum_flux,             & ! intent(in)
                                             stats_metadata,                      & ! intent(in)
                                             stats_zt(i) )                          ! intent(inout)

          call windm_edsclrm_implicit_stats( nz, windm_edsclrm_vm, vm(i,:),       & ! intent(in)
                                             gr%invrs_dzt(i,:),                   & ! intent(in)
                                             lhs_diff(:,i,:), lhs_ma_zt(:,i,:),   & ! intent(in)
                                             invrs_rho_ds_zt(i,:), u_star_sqd(i), & ! intent(in)
                                             rho_ds_zm(i,:), wind_speed(i,:),     & ! intent(in)
                                             l_imp_sfc_momentum_flux,             & ! intent(in)
                                             stats_metadata,                      & ! intent(in)
                                             stats_zt(i) )                          ! intent(inout)
        end do
      end if ! stats_metadata%l_stats_samp
  
      if ( l_lmm_stepping ) then
        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 1, nz
          do i = 1, ngrdcol
            um(i,k) = one_half * ( um_old(i,k) + um(i,k) )
            vm(i,k) = one_half * ( vm_old(i,k) + vm(i,k) )
          end do
        end do
        !$acc end parallel loop
      endif ! l_lmm_stepping ) then

      if ( uv_sponge_damp_settings%l_sponge_damping ) then

        !$acc update host( um, vm, um_ref, vm_ref )
        
        ! _sponge_damp_settings and _sponge_damp_profile could potentially vary
        ! from column to column, but there is no column index in those variables.
        ! Thus this code is potentially unsafe when implemented in a host model, 
        ! which is indicated by l_implemented = T
        if ( l_implemented ) then
          write(fstderr,*) "l_sponge_damping = T and l_implemented = T &
                            -- this is likely unsafe and considered fatal"
          err_code = clubb_fatal_error
          return
        end if
          
        if ( stats_metadata%l_stats_samp ) then
          do i = 1, ngrdcol
            tmp_in(1) = 0.0_core_rknd
            tmp_in(2:nz) = um(i,2:nz)
            call stat_begin_update( nz, stats_metadata%ium_sdmp, tmp_in / dt, & ! intent(in)
                                    stats_zt(i) )           ! intent(inout)
            tmp_in(2:nz) = vm(i,2:nz)
            call stat_begin_update( nz, stats_metadata%ivm_sdmp, tmp_in / dt, & ! intent(in)
                                    stats_zt(i) )           ! intent(inout)
          end do
        end if

        do i = 1, ngrdcol
          um(i,1:nz) = sponge_damp_xm( nz, dt, gr%zt(i,:), gr%zm(i,:), &
                                       um_ref(i,1:nz), um(i,1:nz), uv_sponge_damp_profile )
        end do

        do i = 1, ngrdcol
          vm(i,1:nz) = sponge_damp_xm( nz, dt, gr%zt(i,:), gr%zm(i,:), &
                                       vm_ref(i,1:nz), vm(i,1:nz), uv_sponge_damp_profile )
        end do

        if ( stats_metadata%l_stats_samp ) then
          do i = 1, ngrdcol
            tmp_in(1) = 0.0_core_rknd
            tmp_in(2:nz) = um(i,2:nz)
            call stat_end_update( nz, stats_metadata%ium_sdmp, tmp_in / dt, & ! intent(in) 
                                  stats_zt(i) )           ! intent(inout)
            tmp_in(2:nz) = vm(i,2:nz)
            call stat_end_update( nz, stats_metadata%ivm_sdmp, tmp_in / dt, & ! intent(in)
                                  stats_zt(i) )           ! intent(inout)
          end do
        end if

        !$acc update device( um, vm )

      end if ! uv_sponge_damp_settings%l_sponge_damping

      ! Second part of momentum (implicit component)

      ! Solve for x'w' at all intermediate model levels.
      ! A Crank-Nicholson timestep is used.
      call calc_xpwp( nz, ngrdcol, gr, &
                      Km_zm_p_nu10, um, &
                      xpwp )

      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          upwp(i,k) = upwp(i,k) - one_half * xpwp(i,k)
        end do
      end do
      !$acc end parallel loop
                                                      
      call calc_xpwp( nz, ngrdcol, gr, &
                      Km_zm_p_nu10, vm, &
                      xpwp )
                      
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          vpwp(i,k) = vpwp(i,k) - one_half * xpwp(i,k)
        end do
      end do
      !$acc end parallel loop

      ! Adjust um and vm if nudging is turned on.
      if ( l_uv_nudge ) then

        ! Reflect nudging in budget
        if ( stats_metadata%l_stats_samp ) then
          !$acc update host( um, vm )
          do i = 1, ngrdcol
            tmp_in(1) = 0.0_core_rknd
            tmp_in(2:nz) = um(i,2:nz)
            call stat_begin_update( nz, stats_metadata%ium_ndg, tmp_in / dt, & ! intent(in)
                                    stats_zt(i) )          ! intent(inout)
            tmp_in(2:nz) = vm(i,2:nz)
            call stat_begin_update( nz, stats_metadata%ivm_ndg, tmp_in / dt, & ! intent(in)
                                    stats_zt(i) )          ! intent(inout)
          end do
        end if

        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 1, nz
          do i = 1, ngrdcol
            um(i,k) = um(i,k) - ( ( um(i,k) - um_ref(i,k) ) * (dt/ts_nudge) )
            vm(i,k) = vm(i,k) - ( ( vm(i,k) - vm_ref(i,k) ) * (dt/ts_nudge) )
          end do
        end do
        !$acc end parallel loop

        if ( stats_metadata%l_stats_samp ) then
          !$acc update host( um, vm )
          do i = 1, ngrdcol
            tmp_in(1) = 0.0_core_rknd
            tmp_in(2:nz) = um(i,2:nz)
            call stat_end_update( nz, stats_metadata%ium_ndg, tmp_in / dt, & ! intent(in)
                                  stats_zt(i) )          ! intent(inout)
            tmp_in(2:nz) = vm(i,2:nz)
            call stat_end_update( nz, stats_metadata%ivm_ndg, tmp_in / dt, & ! intent(in)
                                  stats_zt(i) )          ! intent(inout)
          end do
        end if
    
      end if ! l_uv_nudge

      if ( stats_metadata%l_stats_samp ) then
        !$acc update host( um_ref, vm_ref )
        do i = 1, ngrdcol
          tmp_in(1) = 0.0_core_rknd
          tmp_in(2:nz) = um_ref(i,2:nz)
          call stat_update_var( stats_metadata%ium_ref, tmp_in, & ! intent(in)
                                stats_zt(i) )         ! intent(inout)
          tmp_in(2:nz) = vm_ref(i,2:nz)
          call stat_update_var( stats_metadata%ivm_ref, tmp_in, & ! intent(in)
                                stats_zt(i) )         ! intent(inout)
        end do
      end if

      if ( order_windm < order_wp2_wp3 &
          .and. order_windm < order_xp2_xpyp ) then
        l_first_clip_ts = .true.
        l_last_clip_ts = .false.
      elseif ( order_windm > order_wp2_wp3 &
              .and. order_windm > order_xp2_xpyp ) then
        l_first_clip_ts = .false.
        l_last_clip_ts = .true.
      else
        l_first_clip_ts = .false.
        l_last_clip_ts = .false.
      endif

      if ( l_tke_aniso ) then

        ! Clipping for u'w'
        !
        ! Clipping u'w' at each vertical level, based on the
        ! correlation of u and w at each vertical level, such that:
        ! corr_(u,w) = u'w' / [ sqrt(u'^2) * sqrt(w'^2) ];
        ! -1 <= corr_(u,w) <= 1.
        !
        ! Since u'^2, w'^2, and u'w' are each advanced in different
        ! subroutines from each other in advance_clubb_core, clipping for u'w'
        ! has to be done three times during each timestep (once after each
        ! variable has been updated).
        ! This is the third instance of u'w' clipping.
        !l_first_clip_ts = .false.
        !l_last_clip_ts = .true.
        call clip_covar( nz, ngrdcol, gr, clip_upwp, l_first_clip_ts, & ! intent(in)
                         l_last_clip_ts, dt, wp2, up2,                & ! intent(in)
                         l_predict_upwp_vpwp,                         & ! intent(in)
                         stats_metadata,                              & ! intent(in)
                         stats_zm,                                    & ! intent(inout)
                         upwp, upwp_chnge )                             ! intent(inout)

        ! Clipping for v'w'
        !
        ! Clipping v'w' at each vertical level, based on the
        ! correlation of v and w at each vertical level, such that:
        ! corr_(v,w) = v'w' / [ sqrt(v'^2) * sqrt(w'^2) ];
        ! -1 <= corr_(v,w) <= 1.
        !
        ! Since v'^2, w'^2, and v'w' are each advanced in different
        ! subroutines from each other in advance_clubb_core, clipping for v'w'
        ! has to be done three times during each timestep (once after each
        ! variable has been updated).
        ! This is the third instance of v'w' clipping.
        !l_first_clip_ts = .false.
        !l_last_clip_ts = .true.
        call clip_covar( nz, ngrdcol, gr, clip_vpwp, l_first_clip_ts, & ! intent(in)
                         l_last_clip_ts, dt, wp2, vp2,                & ! intent(in)
                         l_predict_upwp_vpwp,                         & ! intent(in)
                         stats_metadata,                              & ! intent(in)
                         stats_zm,                                    & ! intent(inout)
                         vpwp, vpwp_chnge )                             ! intent(inout)
      else

        ! intent(in) this case, it is assumed that
        !   u'^2 == v'^2 == w'^2, and the variables `up2' and `vp2' do not
        ! interact with any other variables.
        !l_first_clip_ts = .false.
        !l_last_clip_ts = .true.
        call clip_covar( nz, ngrdcol, gr, clip_upwp, l_first_clip_ts, & ! intent(in)
                         l_last_clip_ts, dt, wp2, wp2,                & ! intent(in)
                         l_predict_upwp_vpwp,                         & ! intent(in)
                         stats_metadata,                              & ! intent(in)
                         stats_zm,                                    & ! intent(inout)
                         upwp, upwp_chnge )                             ! intent(inout)

        call clip_covar( nz, ngrdcol, gr, clip_vpwp, l_first_clip_ts, & ! intent(in)
                         l_last_clip_ts, dt, wp2, wp2,                & ! intent(in)
                         l_predict_upwp_vpwp,                         & ! intent(in)
                         stats_metadata,                              & ! intent(in)
                         stats_zm,                                    & ! intent(inout)
                         vpwp, vpwp_chnge )                             ! intent(inout)
      endif ! l_tke_aniso

      ! The values of um(1) and vm(1) are located below the model surface and
      ! do not affect the rest of the model.  The values of um(1) or vm(1) are
      ! simply set to the values of um(2) and vm(2), respectively, after the
      ! equation matrices has been solved.  Even though um and vm would sharply
      ! decrease to a value of 0 at the surface, this is done to avoid
      ! confusion on plots of the vertical profiles of um and vm.
      !$acc parallel loop gang vector default(present)
      do i = 1, ngrdcol
        um(i,1) = um(i,2)
        vm(i,1) = vm(i,2)
      end do
      !$acc end parallel loop

    endif ! .not. l_predict_upwp_vpwp

    
    if ( l_perturbed_wind ) then

      !----------------------------------------------------------------
      ! Prepare tridiagonal system for horizontal winds, um and vm
      !----------------------------------------------------------------

      ! Momentum surface fluxes, u'w'|_sfc and v'w'|_sfc, are applied through
      ! an implicit method, such that:
      !    x'w'|_sfc = - ( u_star(t)^2 / wind_speed(t) ) * xm(t+1).
      l_imp_sfc_momentum_flux = .true.

      ! Compute wind speed (use threshold "eps" to prevent divide-by-zero
      ! error).
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 1, nz
        do i = 1, ngrdcol
          wind_speed_pert(i,k) = max( sqrt( (um_pert(i,k))**2 + (vm_pert(i,k))**2 ), eps )
        end do
      end do
      !$acc end parallel loop

      ! Compute u_star_sqd according to the definition of u_star.
      !$acc parallel loop gang vector default(present)
      do i = 1, ngrdcol
        u_star_sqd_pert(i) = sqrt( upwp_pert(i,1)**2 + vpwp_pert(i,1)**2 )
      end do
      !$acc end parallel loop

      ! Compute the explicit portion of the um equation.
      ! Build the right-hand side vector.
      call windm_edsclrm_rhs( nz, ngrdcol, gr, windm_edsclrm_um, dt,    & ! intent(in)
                              lhs_diff, um_pert, um_tndcy,              & ! intent(in)
                              rho_ds_zm, invrs_rho_ds_zt,               & ! intent(in)
                              l_imp_sfc_momentum_flux, upwp_pert(:,1),  & ! intent(in)
                              stats_metadata,                           & ! intent(in)
                              stats_zt,                                 & ! intent(inout)
                              rhs(:,:,windm_edsclrm_um) )                 ! intent(out)
      
      ! Compute the explicit portion of the vm equation.
      ! Build the right-hand side vector.
      call windm_edsclrm_rhs( nz, ngrdcol, gr, windm_edsclrm_vm, dt,    & ! intent(in)
                              lhs_diff, vm_pert, vm_tndcy,              & ! intent(in)
                              rho_ds_zm, invrs_rho_ds_zt,               & ! intent(in)
                              l_imp_sfc_momentum_flux, vpwp_pert(:,1),  & ! intent(in)
                              stats_metadata,                           & ! intent(in)
                              stats_zt,                                 & ! intent(inout)
                              rhs(:,:,windm_edsclrm_vm) )                 ! intent(out)

      ! Store momentum flux (explicit component)

      ! The surface flux, x'w'(1) = x'w'|_sfc, is set elsewhere in the model.
      !      upwp(1) = upwp_sfc
      !      vpwp(1) = vpwp_sfc

      ! Solve for x'w' at all intermediate model levels.
      ! A Crank-Nicholson timestep is used.
      call calc_xpwp( nz, ngrdcol, gr, &
                      Km_zm_p_nu10, um_pert, &
                      xpwp )

      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          upwp_pert(i,k) = -one_half * xpwp(i,k)
        end do
      end do
      !$acc end parallel loop
                                                  
      call calc_xpwp( nz, ngrdcol, gr, &
                      Km_zm_p_nu10, vm_pert, &
                      xpwp )
      
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          vpwp_pert(i,k) = -one_half * xpwp(i,k)
        end do
      end do
      !$acc end parallel loop
      
      ! A zero-flux boundary condition at the top of the model, d(xm)/dz = 0,
      ! means that x'w' at the top model level is 0,
      ! since x'w' = - K_zm * d(xm)/dz.
      !$acc parallel loop gang vector default(present)
      do i = 1, ngrdcol
        upwp_pert(i,nz) = zero
        vpwp_pert(i,nz) = zero
      end do
      !$acc end parallel loop

      ! Compute the implicit portion of the um and vm equations.
      ! Build the left-hand side matrix.
      call windm_edsclrm_lhs( nz, ngrdcol, gr, dt,                        & ! intent(in)
                              lhs_ma_zt, lhs_diff,                        & ! intent(in)
                              wind_speed_pert, u_star_sqd_pert,           & ! intent(in)
                              rho_ds_zm, invrs_rho_ds_zt,                 & ! intent(in)
                              l_implemented, l_imp_sfc_momentum_flux,     & ! intent(in)
                              lhs )                                         ! intent(out)
      
      ! Decompose and back substitute for um and vm
      nrhs = 2
      call windm_edsclrm_solve( nz, ngrdcol, gr, nrhs, stats_metadata%iwindm_matrix_condt_num, & ! intent(in)
                                tridiag_solve_method,                           & ! intent(in)
                                stats_metadata,                                 & ! intent(in)
                                stats_sfc, &                                      ! intent(in)
                                lhs, rhs, &                                       ! intent(inout)
                                solution )                                        ! intent(out)
      
      ! Check for singular matrices and bad LAPACK arguments
      if ( clubb_at_least_debug_level( 0 ) ) then
        if ( err_code == clubb_fatal_error ) then
          write(fstderr,*) "Fatal error solving for um_pert/vm_pert"
          return
        endif
      endif

      !----------------------------------------------------------------
      ! Update zonal (west-to-east) component of mean wind, um
      !----------------------------------------------------------------
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 1, nz
        do i = 1, ngrdcol
          um_pert(i,k) = solution(i,k,windm_edsclrm_um)
        end do
      end do
      !$acc end parallel loop

      !----------------------------------------------------------------
      ! Update meridional (south-to-north) component of mean wind, vm
      !----------------------------------------------------------------
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 1, nz
        do i = 1, ngrdcol
          vm_pert(i,k) = solution(i,k,windm_edsclrm_vm)
        end do
      end do
      !$acc end parallel loop
  
      ! Second part of momentum (implicit component)

      ! Solve for x'w' at all intermediate model levels.
      ! A Crank-Nicholson timestep is used.
      call calc_xpwp( nz, ngrdcol, gr, &
                      Km_zm_p_nu10, um_pert, &
                      xpwp )
      
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          upwp_pert(i,k) = upwp_pert(i,k) - one_half * xpwp(i,k)
        end do
      end do
      !$acc end parallel loop
      
      call calc_xpwp( nz, ngrdcol, gr, &
                      Km_zm_p_nu10, vm_pert, &
                      xpwp )
      
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          vpwp_pert(i,k) = vpwp_pert(i,k) - one_half * xpwp(i,k)
        end do
      end do
      !$acc end parallel loop
      
      if ( l_tke_aniso ) then

        ! Clipping for u'w'
        !
        ! Clipping u'w' at each vertical level, based on the
        ! correlation of u and w at each vertical level, such that:
        ! corr_(u,w) = u'w' / [ sqrt(u'^2) * sqrt(w'^2) ];
        ! -1 <= corr_(u,w) <= 1.
        !
        ! Since u'^2, w'^2, and u'w' are each advanced in different
        ! subroutines from each other in advance_clubb_core, clipping for u'w'
        ! has to be done three times during each timestep (once after each
        ! variable has been updated).
        ! This is the third instance of u'w' clipping.
        l_first_clip_ts = .false.
        l_last_clip_ts = .true.
        call clip_covar( nz, ngrdcol, gr, clip_upwp, l_first_clip_ts, & ! intent(in)
                         l_last_clip_ts, dt, wp2, up2,                & ! intent(in)
                         l_predict_upwp_vpwp,                         & ! intent(in)
                         stats_metadata,                              & ! intent(in)
                         stats_zm,                                    & ! intent(inout)
                         upwp_pert, upwp_chnge )                        ! intent(inout)
        
        ! Clipping for v'w'
        !
        ! Clipping v'w' at each vertical level, based on the
        ! correlation of v and w at each vertical level, such that:
        ! corr_(v,w) = v'w' / [ sqrt(v'^2) * sqrt(w'^2) ];
        ! -1 <= corr_(v,w) <= 1.
        !
        ! Since v'^2, w'^2, and v'w' are each advanced in different
        ! subroutines from each other in advance_clubb_core, clipping for v'w'
        ! has to be done three times during each timestep (once after each
        ! variable has been updated).
        ! This is the third instance of v'w' clipping.
        l_first_clip_ts = .false.
        l_last_clip_ts = .true.
        call clip_covar( nz, ngrdcol, gr, clip_vpwp, l_first_clip_ts, & ! intent(in)
                         l_last_clip_ts, dt, wp2, vp2,                & ! intent(in)
                         l_predict_upwp_vpwp,                         & ! intent(in)
                         stats_metadata,                              & ! intent(in)
                         stats_zm,                                    & ! intent(inout)
                         vpwp_pert, vpwp_chnge )                        ! intent(inout)
      else

        ! intent(in) this case, it is assumed that
        !   u'^2 == v'^2 == w'^2, and the variables `up2' and `vp2' do not
        ! interact with any other variables.
        l_first_clip_ts = .false.
        l_last_clip_ts = .true.
        call clip_covar( nz, ngrdcol, gr, clip_upwp, l_first_clip_ts, & ! intent(in)
                         l_last_clip_ts, dt, wp2, wp2,                & ! intent(in)
                         l_predict_upwp_vpwp,                         & ! intent(in)
                         stats_metadata,                              & ! intent(in)
                         stats_zm,                                    & ! intent(inout)
                         upwp_pert, upwp_chnge )                        ! intent(inout)

        call clip_covar( nz, ngrdcol, gr, clip_vpwp, l_first_clip_ts, & ! intent(in)
                         l_last_clip_ts, dt, wp2, wp2,                & ! intent(in)
                         l_predict_upwp_vpwp,                         & ! intent(in)
                         stats_metadata,                              & ! intent(in)
                         stats_zm,                                    & ! intent(inout)
                         vpwp_pert, vpwp_chnge )                        ! intent(inout)
        
      end if ! l_tke_aniso

      ! The values of um(1) and vm(1) are located below the model surface and
      ! do not affect the rest of the model.  The values of um(1) or vm(1) are
      ! simply set to the values of um(2) and vm(2), respectively, after the
      ! equation matrices has been solved.  Even though um and vm would sharply
      ! decrease to a value of 0 at the surface, this is done to avoid
      ! confusion on plots of the vertical profiles of um and vm.
      !$acc parallel loop gang vector default(present)
      do i = 1, ngrdcol
        um_pert(i,1) = um_pert(i,2)
        vm_pert(i,1) = vm_pert(i,2)
      end do
      !$acc end parallel loop

    end if ! l_perturbed_wind

    !----------------------------------------------------------------
    ! Prepare tridiagonal system for eddy-scalars
    !----------------------------------------------------------------

    if ( edsclr_dim > 0 ) then
      
      Kmh_zt(:,:) = zm2zt( nz, ngrdcol, gr, Kmh_zm(:,:), zero )

      ! Calculate diffusion terms
      call diffusion_zt_lhs( nz, ngrdcol, gr, Kmh_zm, Kmh_zt, nu_zero,  & ! intent(in)
                             invrs_rho_ds_zt, rho_ds_zm,                & ! intent(in)
                             lhs_diff )                                   ! intent(out)

!+++arh
      ! Calculate diffusion terms
      call diffusion_zt_lhs( nz, ngrdcol, gr, scale_fac*Kmh_zm, scale_fac*Kmh_zt, nu_zero,  & ! intent(in)
                             invrs_rho_ds_zt, rho_ds_zm,                & ! intent(in)
                             lhs_diff_scaled )

      ! The lower boundary condition needs to be applied here at level 2.
      if ( .not. l_upwind_Kh_dp_term ) then 

        !$acc parallel loop gang vector default(present)
        do i = 1, ngrdcol
          ! Thermodynamic superdiagonal: [ x xm(k+1,<t+1>) ]
          lhs_diff(kp1_tdiag,i,2) = - gr%invrs_dzt(i,2) * invrs_rho_ds_zt(i,2) &
                                    * ( Kmh_zm(i,2) + nu_zero(i) ) &
                                    * rho_ds_zm(i,2) * gr%invrs_dzm(i,2)

          ! Thermodynamic main diagonal: [ x xm(k,<t+1>) ]
          lhs_diff(k_tdiag,i,2) = + gr%invrs_dzt(i,2) * invrs_rho_ds_zt(i,2) &
                                  * ( Kmh_zm(i,2) + nu_zero(i) ) &
                                  * rho_ds_zm(i,2) * gr%invrs_dzm(i,2)

          ! Thermodynamic subdiagonal: [ x xm(k-1,<t+1>) ]
          lhs_diff(km1_tdiag,i,2) = zero

!+++arh
          ! Thermodynamic superdiagonal: [ x xm(k+1,<t+1>) ]
          lhs_diff_scaled(kp1_tdiag,i,2) = - gr%invrs_dzt(i,2) * invrs_rho_ds_zt(i,2) &
                                    * ( (scale_fac*Kmh_zm(i,2)) + nu_zero(i) ) &
                                    * rho_ds_zm(i,2) * gr%invrs_dzm(i,2)

          ! Thermodynamic main diagonal: [ x xm(k,<t+1>) ]
          lhs_diff_scaled(k_tdiag,i,2) = + gr%invrs_dzt(i,2) * invrs_rho_ds_zt(i,2) &
                                  * ( (scale_fac*Kmh_zm(i,2)) + nu_zero(i) ) &
                                  * rho_ds_zm(i,2) * gr%invrs_dzm(i,2)

          ! Thermodynamic subdiagonal: [ x xm(k-1,<t+1>) ]
          lhs_diff_scaled(km1_tdiag,i,2) = zero
!---arh
        end do
        !$acc end parallel loop

      else

        !$acc parallel loop gang vector default(present)
        do i = 1, ngrdcol
          ! Thermodynamic superdiagonal: [ x xm(k+1,<t+1>) ]
          lhs_diff(kp1_tdiag,i,2) = - gr%invrs_dzt(i,2) &
                                      * ( Kmh_zt(i,2) + nu_zero(i) ) * gr%invrs_dzm(i,2)

          ! Thermodynamic main diagonal: [ x xm(k,<t+1>) ]
          lhs_diff(k_tdiag,i,2) = + gr%invrs_dzt(i,2) &
                                    * ( Kmh_zt(i,2) + nu_zero(i) ) * gr%invrs_dzm(i,2)

          ! Thermodynamic subdiagonal: [ x xm(k-1,<t+1>) ]
          lhs_diff(km1_tdiag,i,2) = zero
        end do
        !$acc end parallel loop

      end if

      if ( l_lmm_stepping ) then
        !$acc parallel loop gang vector collapse(3) default(present)
        do j = 1, edsclr_dim
          do k = 1, nz
            do i = 1, ngrdcol
              edsclrm_old(i,k,j) = edsclrm(i,k,j)
            end do
          end do
        end do
        !$acc end parallel loop
      endif ! l_lmm_stepping

      ! Eddy-scalar surface fluxes, x'w'|_sfc, are applied through an explicit
      ! method.
      l_imp_sfc_momentum_flux = .false.

      ! Compute the explicit portion of eddy scalar equation.
      ! Build the right-hand side vector.
      ! Because of statistics, we have to use a DO rather than a FORALL here
      ! -dschanen 7 Oct 2008
      do edsclr = 1, edsclr_dim
!+++arh
        if (edsclr == edsclr_dim .or. edsclr == edsclr_dim-1) then
          call windm_edsclrm_rhs( nz, ngrdcol, gr, windm_edsclrm_scalar, dt,      & ! intent(in)
                                  lhs_diff_scaled, edsclrm(:,:,edsclr),                  & ! intent(in)
                                  edsclrm_forcing(:,:,edsclr),                    & ! intent(in)
                                  rho_ds_zm, invrs_rho_ds_zt,                     & ! intent(in)
                                  l_imp_sfc_momentum_flux, wpedsclrp(:,1,edsclr), & ! intent(in)
                                  stats_metadata,                                 & ! intent(in)
                                  stats_zt,                                       & ! intent(inout)
                                  rhs(:,:,edsclr) )
        else
          call windm_edsclrm_rhs( nz, ngrdcol, gr, windm_edsclrm_scalar, dt,      & ! intent(in)
                                  lhs_diff, edsclrm(:,:,edsclr),                  & ! intent(in)
                                  edsclrm_forcing(:,:,edsclr),                    & ! intent(in)
                                  rho_ds_zm, invrs_rho_ds_zt,                     & ! intent(in)
                                  l_imp_sfc_momentum_flux, wpedsclrp(:,1,edsclr), & ! intent(in)
                                  stats_metadata,                                 & ! intent(in)
                                  stats_zt,                                       & ! intent(inout)
                                  rhs(:,:,edsclr) )
        end if  
        !call windm_edsclrm_rhs( nz, ngrdcol, gr, windm_edsclrm_scalar, dt,      & ! intent(in)
        !                        lhs_diff, edsclrm(:,:,edsclr),                  & ! intent(in)
        !                        edsclrm_forcing(:,:,edsclr),                    & ! intent(in)
        !                        rho_ds_zm, invrs_rho_ds_zt,                     & ! intent(in)
        !                        l_imp_sfc_momentum_flux, wpedsclrp(:,1,edsclr), & ! intent(in)
        !                        stats_metadata,                                 & ! intent(in)
        !                        stats_zt,                                       & ! intent(inout)
        !                        rhs(:,:,edsclr) )                                 ! intent(out)
!---arh
      enddo


      ! Store momentum flux (explicit component)

      ! The surface flux, x'w'(1) = x'w'|_sfc, is set elsewhere in the model.
      ! wpedsclrp(1,1:edsclr_dim) =  wpedsclrp_sfc(1:edsclr_dim)

      ! Solve for x'w' at all intermediate model levels.
      ! A Crank-Nicholson timestep is used
      do edsclr = 1, edsclr_dim
!+++arh
        if (edsclr == edsclr_dim .or. edsclr == edsclr_dim-1) then
          call calc_xpwp( nz, ngrdcol, gr, &
                          Km_zm_p_nu10_scaled, edsclrm(:,:,edsclr), &
                          xpwp )
        else
          call calc_xpwp( nz, ngrdcol, gr, &
                          Km_zm_p_nu10, edsclrm(:,:,edsclr), &
                          xpwp )
        end if
        !call calc_xpwp( nz, ngrdcol, gr, &
        !                Km_zm_p_nu10, edsclrm(:,:,edsclr), &
        !                xpwp )
!---arh
        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 2, nz-1
          do i = 1, ngrdcol
            wpedsclrp(i,k,edsclr) = -one_half * xpwp(i,k)
          end do
        end do
        !$acc end parallel loop
      end do

      ! A zero-flux boundary condition at the top of the model, d(xm)/dz = 0,
      ! means that x'w' at the top model level is 0,
      ! since x'w' = - K_zm * d(xm)/dz.
      !$acc parallel loop gang vector collapse(2) default(present)
      do j = 1, edsclr_dim
        do i = 1, ngrdcol
          wpedsclrp(i,nz,j) = zero
        end do
      end do
      !$acc end parallel loop

      ! Compute the implicit portion of the xm (eddy-scalar) equations.
      ! Build the left-hand side matrix.
      call windm_edsclrm_lhs( nz, ngrdcol, gr, dt,                    & ! intent(in)
                              lhs_ma_zt, lhs_diff,                    & ! intent(in)
                              wind_speed, u_star_sqd,                 & ! intent(in)
                              rho_ds_zm, invrs_rho_ds_zt,             & ! intent(in)
                              l_implemented, l_imp_sfc_momentum_flux, & ! intent(in)
                              lhs )                                     ! intent(out)
!+++arh
      call windm_edsclrm_lhs( nz, ngrdcol, gr, dt,                    & ! intent(in)
                              lhs_ma_zt, lhs_diff_scaled,                    & ! intent(in)
                              wind_speed, u_star_sqd,                 & ! intent(in)
                              rho_ds_zm, invrs_rho_ds_zt,             & ! intent(in)
                              l_implemented, l_imp_sfc_momentum_flux, & ! intent(in)
                              lhs_scaled )                                     ! intent(out)

!+++arh
      rhs_scaled(:,:,:) = rhs(:,:,:)


      ! Decompose and back substitute for all eddy-scalar variables
      call windm_edsclrm_solve( nz, ngrdcol, gr, edsclr_dim, 0, & ! intent(in)
                                tridiag_solve_method,           & ! intent(in)
                                stats_metadata,                 & ! intent(in)
                                stats_sfc,                      & ! intent(inout)
                                lhs, rhs,                       & ! intent(inout)
                                solution )                        ! intent(out)

!+++arh -- note calling this matrix solver twice and rhs is intent(inout)
      call windm_edsclrm_solve( nz, ngrdcol, gr, edsclr_dim, 0, & ! intent(in)
                                tridiag_solve_method,           & ! intent(in)
                                stats_metadata,                 & ! intent(in)
                                stats_sfc,                      & ! intent(inout)
                                lhs_scaled, rhs_scaled,                       & ! intent(inout)
                                solution_scaled )                        ! intent(out)

!+++arh
      rhs(:,:,edsclr_dim-1:edsclr_dim) = rhs_scaled(:,:,edsclr_dim-1:edsclr_dim)

      if ( clubb_at_least_debug_level( 0 ) ) then
        if ( err_code == clubb_fatal_error ) then
          write(fstderr,*) "Fatal error solving for eddsclrm"
        end if
      end if

      !----------------------------------------------------------------
      ! Update Eddy-diff. Passive Scalars
      !----------------------------------------------------------------
      !$acc parallel loop gang vector collapse(3) default(present)
      do j = 1, edsclr_dim
        do k = 1, nz
          do i = 1, ngrdcol
!+++arh
            if (j == edsclr_dim .or. j == edsclr_dim-1) then
              edsclrm(i,k,j) = solution_scaled(i,k,j)
            else
              edsclrm(i,k,j) = solution(i,k,j)
            end if
            !edsclrm(i,k,j) = solution(i,k,j)
!---arh
          end do
        end do
      end do
      !$acc end parallel loop

      if ( l_lmm_stepping ) then
        !$acc parallel loop gang vector collapse(3) default(present)
        do j = 1, edsclr_dim
          do k = 1, nz
            do i = 1, ngrdcol
              edsclrm(i,k,j) = one_half * ( edsclrm_old(i,k,j) + edsclrm(i,k,j) )
            end do
          end do
        end do
        !$acc end parallel loop
      endif ! l_lmm_stepping

      ! Second part of momentum (implicit component)

      ! Solve for x'w' at all intermediate model levels.
      ! A Crank-Nicholson timestep is used.
      do edsclr = 1, edsclr_dim
!+++arh
        if (edsclr == edsclr_dim .or. edsclr == edsclr_dim-1) then
          call calc_xpwp( nz, ngrdcol, gr, &
                          scale_fac*Kmh_zm, edsclrm(:,:,edsclr), &
                          xpwp )
        else
          call calc_xpwp( nz, ngrdcol, gr, &
                          Kmh_zm, edsclrm(:,:,edsclr), &
                          xpwp )
        end if
        !call calc_xpwp( nz, ngrdcol, gr, &
        !                Kmh_zm, edsclrm(:,:,edsclr), &
        !                xpwp )
!---arh

        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 2, nz-1
          do i = 1, ngrdcol
            wpedsclrp(i,k,edsclr) = -one_half * xpwp(i,k)
          end do
        end do
        !$acc end parallel loop
      end do

      ! Note that the w'edsclr' terms are not clipped, since we don't compute
      ! the variance of edsclr anywhere. -dschanen 7 Oct 2008

      ! The value of edsclrm(1) is located below the model surface and does not
      ! effect the rest of the model.  The value of edsclrm(1) is simply set to
      ! the value of edsclrm(2) after the equation matrix has been solved.
      !$acc parallel loop gang vector collapse(2) default(present)
      do edsclr = 1, edsclr_dim
        do i = 1, ngrdcol
          edsclrm(i,1,edsclr) = edsclrm(i,2,edsclr)
        end do
      end do
      !$acc end parallel loop

    endif

    if ( clubb_at_least_debug_level( 0 ) ) then
        if ( err_code == clubb_fatal_error ) then

          !$acc update host( wm_zt, Km_zm, ug, vg, um_ref, vm_ref, wp2, &
          !$acc              up2, vp2, um_forcing, vm_forcing, edsclrm_forcing, &
          !$acc              fcor, um_old, um, vm_old, vm, edsclrm_old, &
          !$acc              edsclrm, upwp, vpwp, wpedsclrp )

          write(fstderr,*) "Error in advance_windm_edsclrm"

          write(fstderr,*) "intent(in)"

          write(fstderr,*) "dt = ", dt
          write(fstderr,*) "wm_zt = ", wm_zt
          write(fstderr,*) "Km_zm = ", Km_zm
          write(fstderr,*) "ug = ", ug
          write(fstderr,*) "vg = ", vg
          write(fstderr,*) "um_ref = ", um_ref
          write(fstderr,*) "vm_ref = ", vm_ref
          write(fstderr,*) "wp2 = ", wp2
          write(fstderr,*) "up2 = ", up2
          write(fstderr,*) "vp2 = ", vp2
          write(fstderr,*) "um_forcing = ", um_forcing
          write(fstderr,*) "vm_forcing = ", vm_forcing
          do edsclr = 1, edsclr_dim
            write(fstderr,*) "edsclrm_forcing # = ",edsclr, edsclrm_forcing
          end do
          write(fstderr,*) "fcor = ", fcor
          write(fstderr,*) "l_implemented = ", l_implemented

          write(fstderr,*) "intent(inout)"

          if ( l_lmm_stepping ) &
             write(fstderr,*) "um (pre-solve) = ", um_old
          write(fstderr,*) "um = ", um
          if ( l_lmm_stepping ) &
             write(fstderr,*) "vm (pre-solve) = ", vm_old
          write(fstderr,*) "vm = ", vm
          do edsclr = 1, edsclr_dim
            if ( l_lmm_stepping ) &
               write(fstderr,*) "edsclrm (pre-solve) # ", edsclr, "=", edsclrm_old(:,:,edsclr)
            write(fstderr,*) "edsclrm # ", edsclr, "=", edsclrm(:,:,edsclr)
          end do
          write(fstderr,*) "upwp = ", upwp
          write(fstderr,*) "vpwp = ", vpwp
          write(fstderr,*) "wpedsclrp = ", wpedsclrp

          return
        end if
    end if

    !$acc exit data delete( um_old, vm_old, um_tndcy, vm_tndcy, &
    !$acc                    upwp_chnge, vpwp_chnge, lhs, rhs, solution, wind_speed, &
    !$acc                    wind_speed_pert, u_star_sqd, u_star_sqd_pert, &
    !$acc                    nu_zero, lhs_diff, lhs_ma_zt, Km_zt, Kmh_zt, &
    !$acc                    Km_zm_p_nu10, xpwp )

    !$acc exit data if( edsclr_dim > 0) delete( edsclrm_old )

    return

  end subroutine advance_windm_edsclrm

  !=============================================================================
  subroutine windm_edsclrm_solve( nz, ngrdcol, gr, nrhs, ixm_matrix_condt_num, &
                                  tridiag_solve_method, &
                                  stats_metadata, &
                                  stats_sfc, & 
                                  lhs, rhs, solution )

    ! Note:  In the "Description" section of this subroutine, the variable
    !        "invrs_dzm" will be written as simply "dzm", and the variable
    !        "invrs_dzt" will be written as simply "dzt".  This is being done as
    !        as device to save space and to make some parts of the description
    !        more readable.  This change does not pertain to the actual code.

    ! Description:
    ! Solves the horizontal wind or eddy-scalar time-tendency equation, and
    ! diagnoses the turbulent flux.  A Crank-Nicholson time-stepping algorithm
    ! is used in solving the turbulent advection term and in diagnosing the
    ! turbulent flux.
    !
    ! The rate of change of an eddy-scalar quantity, xm, is:
    !
    ! d(xm)/dt = - w * d(xm)/dz - (1/rho_ds) * d( rho_ds * x'w' )/dz 
    !            + xm_forcings.
    !
    !
    ! The Turbulent Advection Term
    ! ----------------------------
    !
    ! The above equation contains a turbulent advection term:
    !
    ! - (1/rho_ds) * d( rho_ds * x'w' )/dz;
    !
    ! where the momentum flux, x'w', is closed using a down gradient approach:
    !
    ! x'w' = - K_zm * d(xm)/dz.
    !
    ! The turbulent advection term becomes:
    !
    ! + (1/rho_ds) * d [ rho_ds * K_zm * d(xm)/dz ] / dz;
    !
    ! which is the same as a standard eddy-diffusion term (if "rho_ds * K_zm" in
    ! the term above is substituted for "K_zm" in a standard eddy-diffusion
    ! term, and if the standard eddy-diffusion term is multiplied by
    ! "1/rho_ds").  Thus, the turbulent advection term is treated and solved in
    ! the same way that a standard eddy-diffusion term would be solved.  The
    ! term is discretized as follows:
    !
    ! The values of xm are found on the thermodynamic levels, while the values
    ! of K_zm are found on the momentum levels.  Additionally, the values of
    ! rho_ds_zm are found on the momentum levels, and the values of
    ! invrs_rho_ds_zt are found on the thermodynamic levels.  The
    ! derivatives (d/dz) of xm are taken over the intermediate momentum levels.
    ! At the intermediate momentum levels, d(xm)/dz is multiplied by K_zm and by
    ! rho_ds_zm.  Then, the derivative of the whole mathematical expression is
    ! taken over the central thermodynamic level, where it is multiplied by
    ! invrs_rho_ds_zt, which yields the desired result.
    !
    ! ---xm(kp1)----------------------------------------------------- t(k+1)
    !
    ! ===========d(xm)/dz===K_zm(k)=====rho_ds_zm(k)================= m(k)
    !
    ! ---xm(k)---invrs_rho_ds_zt---d[rho_ds_zm*K_zm*d(xm)/dz]/dz----- t(k)
    !
    ! ===========d(xm)/dz===K_zm(km1)===rho_ds_zm(km1)=============== m(k-1)
    !
    ! ---xm(km1)----------------------------------------------------- t(k-1)
    !
    ! The vertical indices t(k+1), m(k), t(k), m(k-1), and t(k-1) correspond
    ! with altitudes zt(k+1), zm(k), zt(k), zm(k-1), and zt(k-1), respectively.
    ! The letter "t" is used for thermodynamic levels and the letter "m" is used
    ! for momentum levels.
    !
    ! dzt(k)   = 1 / ( zm(k) - zm(k-1) )
    ! dzm(k)   = 1 / ( zt(k+1) - zt(k) )
    ! dzm(k-1) = 1 / ( zt(k) - zt(k-1) )
    !
    ! The vertically discretized form of the turbulent advection term (treated
    ! as an eddy diffusion term) is written out as:
    !
    ! + invrs_rho_ds_zt(k)
    !   * dzt(k)
    !     * [   rho_ds_zm(k) * K_zm(k) * dzm(k) * ( xm(k+1) - xm(k) )
    !         - rho_ds_zm(k-1) * K_zm(k-1) * dzm(k-1) * ( xm(k) - xm(k-1) ) ].
    !
    ! For this equation, a Crank-Nicholson (semi-implicit) diffusion scheme is
    ! used to solve the (1/rho_ds) * d [ rho_ds * K_zm * d(xm)/dz ] / dz
    ! eddy-diffusion term.  The discretized implicit portion of the term is
    ! written out as:
    !
    ! + (1/2) * invrs_rho_ds_zt(k)
    !   * dzt(k)
    !     * [   rho_ds_zm(k) * K_zm(k)
    !           * dzm(k) * ( xm(k+1,<t+1>) - xm(k,<t+1>) )
    !         - rho_ds_zm(k-1) * K_zm(k-1)
    !           * dzm(k-1) * ( xm(k,<t+1>) - xm(k-1,<t+1>) ) ].
    !
    ! Note:  When the implicit term is brought over to the left-hand side,
    !        the sign is reversed and the leading "+" in front of the term
    !        is changed to a "-".
    !
    ! The discretized explicit portion of the term is written out as:
    !
    ! + (1/2) * invrs_rho_ds_zt(k)
    !   * dzt(k)
    !     * [   rho_ds_zm(k) * K_zm(k)
    !           * dzm(k) * ( xm(k+1,<t>) - xm(k,<t>) )
    !         - rho_ds_zm(k-1) * K_zm(k-1)
    !           * dzm(k-1) * ( xm(k,<t>) - xm(k-1,<t>) ) ].
    !
    ! Timestep index (t) stands for the index of the current timestep, while
    ! timestep index (t+1) stands for the index of the next timestep, which is
    ! being advanced to in solving the d(xm)/dt equation.
    !
    !
    ! Boundary Conditions:
    !
    ! An eddy-scalar quantity is not allowed to flux out the upper boundary.
    ! Thus, a zero-flux boundary condition is used for the upper boundary in the
    ! eddy-diffusion equation.
    !
    ! The lower boundary condition is much more complicated.  It is neither a
    ! zero-flux nor a fixed-point boundary condition.  Rather, it is a
    ! fixed-flux boundary condition.  This term is a turbulent advection term,
    ! but with the eddy-scalars, the only value of x'w' relevant in solving the
    ! d(xm)/dt equation is the value of x'w' at the surface (the first momentum
    ! level), which is written as x'w'|_sfc.
    !
    ! 1) x'w' surface flux; generalized explicit form
    !
    !    The x'w' surface flux is applied to the d(xm)/dt equation through the
    !    turbulent advection term, which is:
    !
    !    - (1/rho_ds) * d( rho_ds * x'w' )/dz.
    !
    !    At most vertical levels, a substitution can be made for x'w', such
    !    that:
    !
    !    x'w' = - K_zm * d(xm)/dz.
    !
    !    However, the same substitution cannot be made at the surface (momentum
    !    level 1), as x'w'|_sfc is a surface flux that is explicitly computed
    !    elsewhere in the model code.
    !
    !    The lower boundary condition, which in this case needs to be applied to
    !    the d(xm)/dt equation at level 2, is discretized as follows:
    !
    !    --xm(3)------------------------------------------------------- t(3)
    !
    !    ========[x'w'(2) = -K_zm(2)*d(xm)/dz]===rho_ds_zm(2)========== m(2)
    !
    !    --xm(2)---invrs_rho_ds_zt(2)---d[rho_ds_zm*K_zm*d(xm)/dz]/dz-- t(2)
    !
    !    ========[x'w'|_sfc]=====================rho_ds_zm(1)========== m(1) sfc
    !
    !    --xm(1)-------(below surface; not applicable)----------------- t(1)
    !
    !    where "sfc" is the level of the model surface or lower boundary.
    !
    !    The vertically discretized form of the turbulent advection term
    !    (treated as an eddy diffusion term), with the explicit surface flux,
    !    x'w'|_sfc, in place, is written out as:
    !
    !    - invrs_rho_ds_zt(2)
    !      * dzt(2) * [ rho_ds_zm(2) * x'w'(2) - rho_ds_zm(1) * x'w'|_sfc ];
    !
    !    which can be re-written as:
    !
    !    + invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * [   rho_ds_zm(2) * K_zm(2) * dzm(2) * ( xm(3) - xm(2) )
    !            + rho_ds_zm(1) * x'w'|_sfc ];
    !
    !    which can be re-written again as:
    !
    !    + invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * rho_ds_zm(2) * K_zm(2) * dzm(2) * ( xm(3) - xm(2) )
    !    + invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * rho_ds_zm(1) * x'w'|_sfc.
    !
    !    For this equation, a Crank-Nicholson (semi-implicit) diffusion scheme
    !    is used to solve the (1/rho_ds) * d [ rho_ds * K_zm * d(xm)/dz ] / dz
    !    eddy-diffusion term.  The discretized implicit portion of the term is
    !    written out as:
    !
    !    + (1/2) * invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * [ rho_ds_zm(2) * K_zm(2)
    !            * dzm(2) * ( xm(3,<t+1>) - xm(2,<t+1>) ) ].
    !
    !    Note:  When the implicit term is brought over to the left-hand side,
    !           the sign is reversed and the leading "+" in front of the term
    !           is changed to a "-".
    !
    !    The discretized explicit portion of the term is written out as:
    !
    !    + (1/2) * invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * [ rho_ds_zm(2) * K_zm(2)
    !            * dzm(2) * ( xm(3,<t>) - xm(2,<t>) ) ]
    !    + invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * rho_ds_zm(1) * x'w'|_sfc.
    !
    !    Note:  The x'w'|_sfc portion of the term written above has been pulled
    !           away from the rest of the explicit form written above because
    !           the (1/2) factor due to Crank-Nicholson time_stepping does not
    !           apply to it, as there isn't an implicit portion for x'w'|_sfc.
    !
    !    Timestep index (t) stands for the index of the current timestep, while
    !    timestep index (t+1) stands for the index of the next timestep, which
    !    is being advanced to in solving the d(xm)/dt equation.
    !
    ! 2) x'w' surface flux; implicit form for momentum fluxes u'w' and v'w'
    !
    !    The x'w' surface flux is applied to the d(xm)/dt equation through the
    !    turbulent advection term, which is:
    !
    !    - (1/rho_ds) * d( rho_ds * x'w' )/dz.
    !
    !    At most vertical levels, a substitution can be made for x'w', such
    !    that:
    !
    !    x'w' = - K_zm * d(xm)/dz.
    !
    !    However, the same substitution cannot be made at the surface (momentum
    !    level 1), as x'w'|_sfc is a surface momentum flux that is found by the
    !    following equation:
    !
    !    x'w'|_sfc = - [ u_star^2 / sqrt( um^2 + vm^2 ) ] * xm;
    !
    !    where x'w'|_sfc and xm are either u'w'|_sfc and um, respectively, or
    !    v'w'|_sfc and vm, respectively (um and vm are located at the first
    !    thermodynamic level above the surface, which is thermodynamic level 2),
    !    sqrt( um^2 + vm^2 ) is the wind speed (also at thermodynamic level 2),
    !    and u_star is defined as:
    !
    !    u_star = ( u'w'|_sfc^2 + v'w'|_sfc^2 )^(1/4);
    !
    !    and thus u_star^2 is defined as:
    !
    !    u_star^2 = sqrt( u'w'|_sfc^2 + v'w'|_sfc^2 ).
    !
    !    The value of u_star is either set to a constant value or computed
    !    (through function diag_ustar) based on the surface wind speed, the
    !    height above surface of the surface wind speed (as compared to the
    !    roughness height), and the buoyancy flux at the surface.  Either way,
    !    u_star is computed elsewhere in the model, and the values of u'w'|_sfc
    !    and v'w'|_sfc are based on it and computed along with it.  The values
    !    of u'w'|_sfc and v'w'|_sfc are then passed into advance_clubb_core,
    !    and are eventually passed into advance_windm_edsclrm.  In subroutine
    !    advance_windm_edsclrm, the value of u_star_sqd is then recomputed
    !    based on u'w'|_sfc and v'w'|_sfc.  The value of sqrt( u_star_sqd ) is
    !    consistent with the value of the original computation of u_star.
    !
    !    The equation listed above is substituted for x'w'|_sfc.  The lower
    !    boundary condition, which in this case needs to be applied to the
    !    d(xm)/dt equation at level 2, is discretized as follows:
    !
    !    --xm(3)------------------------------------------------------- t(3)
    !
    !    ===[x'w'(2) = -K_zm(2)*d(xm)/dz]=================rho_ds_zm(2)= m(2)
    !
    !    --xm(2)---invrs_rho_ds_zt(2)---d[rho_ds_zm*K_zm*d(xm)/dz]/dz-- t(2)
    !
    !    ===[x'w'|_sfc = -[u_star^2/sqrt(um^2+vm^2)]*xm]==rho_ds_zm(1)= m(1) sfc
    !
    !    --xm(1)-------(below surface; not applicable)----------------- t(1)
    !
    !    where "sfc" is the level of the model surface or lower boundary.
    !
    !    The vertically discretized form of the turbulent advection term
    !    (treated as an eddy diffusion term), with the implicit surface momentum
    !    flux in place, is written out as:
    !
    !    - invrs_rho_ds_zt(2)
    !      * dzt(2) * [ rho_ds_zm(2) * x'w'(2) - rho_ds_zm(1) * x'w'|_sfc ];
    !
    !    which can be re-written as:
    !
    !    - invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * [   rho_ds_zm(2)
    !              * { - K_zm(2) * dzm(2) * ( xm(3) - xm(2) ) }
    !            - rho_ds_zm(1)
    !              * { - [ u_star^2 / sqrt( um(2)^2 + vm(2)^2 ) ] * xm(2) } ];
    !
    !    which can be re-written as:
    !
    !    + invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * rho_ds_zm(2) * K_zm(2) * dzm(2) * ( xm(3) - xm(2) )
    !    - invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * rho_ds_zm(1) * [ u_star^2 / sqrt( um(2)^2 + vm(2)^2 ) ] * xm(2).
    !
    !    For this equation, a Crank-Nicholson (semi-implicit) diffusion scheme
    !    is used to solve the (1/rho_ds) * d [ rho_ds * K_zm * d(xm)/dz ] / dz
    !    eddy-diffusion term.  The discretized implicit portion of the term is
    !    written out as:
    !
    !    + (1/2) * invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * [ rho_ds_zm(2) * K_zm(2)
    !            * dzm(2) * ( xm(3,<t+1>) - xm(2,<t+1>) ) ]
    !    - invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * rho_ds_zm(1) 
    !        * [u_star^2/sqrt( um(2,<t>)^2 + vm(2,<t>)^2 )] * xm(2,<t+1>).
    !
    !    Note:  When the implicit term is brought over to the left-hand side,
    !           the signs are reversed and the leading "+" in front of the first
    !           part of the term is changed to a "-", while the leading "-" in
    !           front of the second part of the term is changed to a "+".
    !
    !    Note:  The x'w'|_sfc portion of the term written above has been pulled
    !           away from the rest of the implicit form written above because
    !           the (1/2) factor due to Crank-Nicholson time_stepping does not
    !           apply to it.  The x'w'|_sfc portion of the term is treated
    !           completely implicitly in order to enhance numerical stability.
    !
    !    The discretized explicit portion of the term is written out as:
    !
    !    + (1/2) * invrs_rho_ds_zt(2)
    !      * dzt(2)
    !        * [ rho_ds_zm(2) * K_zm(2)
    !            * dzm(2) * ( xm(3,<t>) - xm(2,<t>) ) ].
    !
    !    Timestep index (t) stands for the index of the current timestep, while
    !    timestep index (t+1) stands for the index of the next timestep, which
    !    is being advanced to in solving the d(xm)/dt equation.
    !
    !
    ! The lower boundary condition for the implicit and explicit portions of the
    ! turbulent advection term, without the x'w'|_sfc portion of the term, can
    ! easily be invoked by using the zero-flux boundary conditions found in the
    ! generalized diffusion function (function diffusion_zt_lhs), which is used
    ! for many other equations in this model.  Either the generalized explicit
    ! surface flux needs to be added onto the explicit term after the diffusion
    ! function has been called from subroutine windm_edsclrm_rhs, or the
    ! implicit momentum surface flux needs to be added onto the implicit term
    ! after the diffusion function has been called from subroutine
    ! windm_edsclrm_lhs.  However, all other equations in this model that use
    ! zero-flux diffusion have level 1 as the level to which the lower boundary
    ! condition needs to be applied.  Thus, an adjuster will have to be used at
    ! level 2 to call diffusion_zt_lhs with level 1 as the input level (the last
    ! variable being passed in during the function call).  However, the other
    ! variables passed in (rho_ds_zm*K_zm, gr%dzt(1,:), and gr%dzm(1,:) variables) will
    ! have to be passed in as solving for level 2.
    !
    ! The value of xm(1) is located below the model surface and does not effect
    ! the rest of the model.  Since xm can be either a horizontal wind component
    ! or a generic eddy scalar quantity, the value of xm(1) is simply set to the
    ! value of xm(2) after the equation matrix has been solved.
    !
    !
    ! Conservation Properties:
    !
    ! When a fixed-flux lower boundary condition is used (combined with a
    ! zero-flux upper boundary condition), this technique of discretizing the
    ! turbulent advection term (treated as an eddy-diffusion term) leads to
    ! conservative differencing.  When the implicit momentum surface flux is
    ! either zero or not used, the column totals for each column in the
    ! left-hand side matrix (for the turbulent advection term) should be equal
    ! to 0.  Otherwise, the column total for the second column will be equal to
    ! rho_ds_zm(1) * x'w'|_sfc<t+1>.   When the generalized explicit surface
    ! flux is either zero or not used, the column total for the right-hand side
    ! vector (for the turbulent advection term) should be equal to 0.
    ! Otherwise, the column total for the right-hand side vector (for the
    ! turbulent advection term) will be equal to rho_ds_zm(1) * x'w'|_sfc<t>.
    ! This ensures that the total amount of quantity xm over the entire vertical
    ! domain is only changed by the surface flux (neglecting any forcing terms).
    ! The total amount of change is equal to rho_ds_zm(1) * x'w'|_sfc.
    !
    ! To see that this conservation law is satisfied by the left-hand side
    ! matrix, compute the turbulent advection (treated as eddy diffusion) of xm,
    ! neglecting any implicit momentum surface flux, multiply by rho_ds_zt, and
    ! integrate vertically.  In discretized matrix notation (where "i" stands
    ! for the matrix column and "j" stands for the matrix row):
    !
    !  0 = Sum_j Sum_i
    !       (rho_ds_zt)_i ( 1/dzt )_i
    !       ( 0.5_core_rknd * (1/rho_ds_zt) * dzt * (rho_ds_zm*K_zm*dzm) )_ij (xm<t+1>)_j.
    !
    ! The left-hand side matrix,
    ! ( 0.5_core_rknd * (1/rho_ds_zt) * dzt * (rho_ds_zm*K_zm*dzm) )_ij, is partially
    ! written below.  The sum over i in the above equation removes (1/rho_ds_zt)
    ! and dzt everywhere from the matrix below.  The sum over j leaves the
    ! column totals that are desired, which are 0.
    !
    ! Left-hand side matrix contributions from the turbulent advection term
    ! (treated as an eddy-diffusion term using a Crank-Nicholson timestep);
    ! first five vertical levels:
    !
    !     ------------------------------------------------------------------------------->
    !k=1 |  0             0                        0                          0
    !    |
    !k=2 |  0   +0.5*                  -0.5*                                  0
    !    |        (1/rho_ds_zt(k))*      (1/rho_ds_zt(k))*
    !    |        dzt(k)*                dzt(k)*
    !    |        rho_ds_zm(k)*          rho_ds_zm(k)*
    !    |        K_zm(k)*dzm(k)         K_zm(k)*dzm(k)
    !    |
    !k=3 |  0   -0.5*                  +0.5*                      -0.5*
    !    |        (1/rho_ds_zt(k))*      (1/rho_ds_zt(k))*          (1/rho_ds_zt(k))*
    !    |        dzt(k)*                dzt(k)*                    dzt(k)*
    !    |        rho_ds_zm(k-1)*        [ rho_ds_zm(k)*            rho_ds_zm(k)*
    !    |        K_zm(k-1)*dzm(k-1)       K_zm(k)*dzm(k)           K_zm(k)*dzm(k)
    !    |                                +rho_ds_zm(k-1)*
    !    |                                 K_zm(k-1)*dzm(k-1) ]
    !    |
    !k=4 |  0             0            -0.5*                      +0.5*
    !    |                               (1/rho_ds_zt(k))*          (1/rho_ds_zt(k))*
    !    |                               dzt(k)*                    dzt(k)*
    !    |                               rho_ds_zm(k-1)*            [ rho_ds_zm(k)*
    !    |                               K_zm(k-1)*dzm(k-1)           K_zm(k)*dzm(k)
    !    |                                                           +rho_ds_zm(k-1)*
    !    |                                                            K_zm(k-1)*dzm(k-1) ]
    !    |
    !k=5 |  0             0                        0              -0.5*
    !    |                                                          (1/rho_ds_zt(k))*
    !    |                                                          dzt(k)*
    !    |                                                          rho_ds_zm(k-1)*
    !    |                                                          K_zm(k-1)*dzm(k-1)
    !   \ /
    !
    ! Note:  The superdiagonal term from level 4 and both the main diagonal and
    !        superdiagonal terms from level 5 are not shown on this diagram.
    !
    ! Note:  If an implicit momentum surface flux is used, an additional term,
    !        + (1/rho_ds_zt(2)) * dzt(2) * rho_ds_zm(1)
    !          * [ u_star^2 / sqrt( um(2,<t>)^2 + vm(2,<t>)^2 ) ], is added to
    !        row 2 (k=2), column 2.
    !
    ! To see that the above conservation law is satisfied by the right-hand side
    ! vector, compute the turbulent advection (treated as eddy diffusion) of xm,
    ! neglecting any generalized explicit surface flux, multiply by rho_ds_zt,
    ! and integrate vertically.  In discretized matrix notation (where "i"
    ! stands for the matrix column and "j" stands for the matrix row):
    !
    !  0 = Sum_j Sum_i (rho_ds_zt)_i ( 1/dzt )_i ( rhs_vector )_j.
    !
    ! The right-hand side vector, ( rhs_vector )_j, is partially written below.
    ! The sum over i in the above equation removes (1/rho_ds_zt) and dzt
    ! everywhere from the vector below.  The sum over j leaves the column total
    ! that is desired, which is 0.
    !
    ! Right-hand side vector contributions from the turbulent advection term
    ! (treated as an eddy-diffusion term using a Crank-Nicholson timestep);
    ! first five vertical levels:
    !
    !     --------------------------------------------
    !k=1 |                      0                     |
    !    |                                            |
    !    |                                            |
    !k=2 | +0.5*(1/rho_ds_zt(k))*                     |
    !    |      dzt(k)*                               |
    !    |       [ rho_ds_zm(k)*K_zm(k)*              |
    !    |         dzm(k)*(xm(k+1,<t>)-xm(k,<t>)) ]   |
    !    |                                            |
    !k=3 | +0.5*(1/rho_ds_zt(k))*                     |
    !    |      dzt(k)*                               |
    !    |       [ rho_ds_zm(k)*K_zm(k)*              |
    !    |         dzm(k)*(xm(k+1,<t>)-xm(k,<t>))     |
    !    |        -rho_ds_zm(k-1)*K_zm(k-1)*          |
    !    |         dzm(k-1)*(xm(k,<t>)-xm(k-1,<t>)) ] |
    !    |                                            |
    !k=4 | +0.5*(1/rho_ds_zt(k))*                     |
    !    |      dzt(k)*                               |
    !    |       [ rho_ds_zm(k)*K_zm(k)*              |
    !    |         dzm(k)*(xm(k+1,<t>)-xm(k,<t>))     |
    !    |        -rho_ds_zm(k-1)*K_zm(k-1)*          |
    !    |         dzm(k-1)*(xm(k,<t>)-xm(k-1,<t>)) ] |
    !    |                                            |
    !k=5 | +0.5*(1/rho_ds_zt(k))*                     |
    !    |      dzt(k)*                               |
    !    |       [ rho_ds_zm(k)*K_zm(k)*              |
    !    |         dzm(k)*(xm(k+1,<t>)-xm(k,<t>))     |
    !    |        -rho_ds_zm(k-1)*K_zm(k-1)*          |
    !    |         dzm(k-1)*(xm(k,<t>)-xm(k-1,<t>)) ] |
    !   \ /                                          \ /
    !
    ! Note:  If a generalized explicit surface flux is used, an additional term,
    !        + (1/rho_ds_zt(2)) * dzt(2) * rho_ds_zm(1) * x'w'|_sfc, is added to
    !        row 2 (k=2).
    !
    ! Note:  Only the contributions by the turbulent advection term are shown
    !        for both the left-hand side matrix and the right-hand side vector.
    !        There are more terms in the equation, and thus more factors to be
    !        added to both the left-hand side matrix (such as time tendency and
    !        mean advection) and the right-hand side vector (such as xm
    !        forcings).  The left-hand side matrix is set-up so that a singular
    !        matrix is not encountered.

    ! References:
    ! Eqn. 8 & 9 on p. 3545 of
    ! ``A PDF-Based Model for Boundary Layer Clouds. Part I:
    !   Method and Model Description'' Golaz, et al. (2002)
    ! JAS, Vol. 59, pp. 3540--3551.
    !-----------------------------------------------------------------------

    use grid_class, only: & 
        grid ! Type

    use matrix_solver_wrapper, only:  & 
        tridiag_solve ! Procedure(s)

    use stats_variables, only: &
        stats_metadata_type

    use stats_type_utilities, only:  &
        stat_update_var_pt  ! Subroutine

    use clubb_precision, only: &
        core_rknd ! Variable(s)

    use stats_type, only: stats ! Type

    implicit none

    ! Constant parameters

    integer, parameter :: &
      kp1_tdiag = 1, & ! Thermodynamic superdiagonal index.
      k_tdiag   = 2, & ! Thermodynamic main diagonal index.
      km1_tdiag = 3    ! Thermodynamic subdiagonal index.

    ! ------------------------ Input Variables ------------------------
    integer, intent(in) :: &
      nz, &
      ngrdcol
    
    type (grid), target, intent(in) :: &
      gr

    integer, intent(in) :: &
      nrhs ! Number of right-hand side (explicit) vectors & Number of solution vectors.

    integer, intent(in) :: &
      ixm_matrix_condt_num  ! Stats index of the condition numbers

    integer, intent(in) :: &
      tridiag_solve_method  ! Specifier for method to solve tridiagonal systems

    type (stats_metadata_type), intent(in) :: &
      stats_metadata

    ! ------------------------ Inout variables ------------------------
    type (stats), target, dimension(ngrdcol), intent(inout) :: &
      stats_sfc
      
    real( kind = core_rknd ), dimension(3,ngrdcol,nz), intent(inout) :: &
      lhs    ! Implicit contributions to um, vm, and eddy scalars  [units vary]

    real( kind = core_rknd ), dimension(ngrdcol,nz,nrhs), intent(inout) :: &
      rhs    ! Right-hand side (explicit) contributions.

    ! ------------------------ Output variables ------------------------
    real( kind = core_rknd ), dimension(ngrdcol,nz,nrhs), intent(out) :: &
      solution ! Solution to the system of equations    [units vary]

    ! ------------------------ Local variables ------------------------
    real( kind = core_rknd ), dimension(ngrdcol) :: &
      rcond ! Estimate of the reciprocal of the condition number on the LHS matrix

    integer :: i
    
    ! ------------------------ Begin Code ------------------------

    ! Solve tridiagonal system for xm.
    if ( stats_metadata%l_stats_samp .and. ixm_matrix_condt_num > 0 ) then

      call tridiag_solve( "windm_edsclrm", tridiag_solve_method,  & ! Intent(in) 
                          ngrdcol, nz, nrhs,                      & ! Intent(in) 
                          lhs, rhs,                               & ! Intent(inout)
                          solution, rcond )                         ! Intent(out)

      ! Est. of the condition number of the variance LHS matrix
      do i = 1, ngrdcol
        call stat_update_var_pt( ixm_matrix_condt_num, 1, 1.0_core_rknd/rcond(i), &  ! intent(in)
                                 stats_sfc(i) )                                      ! intent(inout)
      end do
    else

      call tridiag_solve( "windm_edsclrm", tridiag_solve_method,  & ! Intent(in) 
                          ngrdcol, nz, nrhs,                      & ! Intent(in) 
                          lhs, rhs,                               & ! Intent(inout)
                          solution )                                ! Intent(out)
    end if

    return
  end subroutine windm_edsclrm_solve

  !=============================================================================
  subroutine windm_edsclrm_implicit_stats( nz, solve_type, xm, &
                                           invrs_dzt, & 
                                           lhs_diff, lhs_ma_zt, & 
                                           invrs_rho_ds_zt, u_star_sqd,&
                                           rho_ds_zm, wind_speed, &
                                           l_imp_sfc_momentum_flux, &
                                           stats_metadata, &
                                           stats_zt ) 

    ! Description:
    ! Compute implicit contributions to um and vm

    ! References:
    ! None
    !-----------------------------------------------------------------------
        
    use constants_clubb, only: &
        zero

    use stats_type_utilities, only:  &
        stat_end_update_pt,  & ! Subroutines
        stat_update_var_pt

    use clubb_precision, only:  & 
        core_rknd

    use stats_type, only: &
        stats ! Type

    use stats_variables, only: &
        stats_metadata_type

    implicit none

    !---------------------- Input Variables ----------------------
    integer, intent(in) :: &
      nz
    
    integer, intent(in) :: & 
      solve_type     ! Desc. of what is being solved for

    real( kind = core_rknd ), dimension(nz), intent(in) :: &
      xm,         & !  Computed value um or vm at <t+1>    [m/s]
      invrs_dzt     ! The inverse spacing between momentum grid levels;
                    ! centered over thermodynamic grid levels.
      
    real( kind = core_rknd ), dimension(3,nz), intent(in) :: &
      lhs_diff, & ! LHS diffustion terms
      lhs_ma_zt   ! LHS mean advection terms
      
    real( kind = core_rknd ), dimension(nz), intent(in) ::  &
      wind_speed,      & ! wind speed; sqrt(u^2 + v^2)              [m/s]
      rho_ds_zm,       & ! Dry, static density on momentum levels      [kg/m^3]
      invrs_rho_ds_zt    ! Inv. dry, static density at thermo. levels  [m^3/kg]
      
    real( kind = core_rknd ), intent(in) :: &
      u_star_sqd   ! Surface friction velocity, u_star, squared      [m/s]
      
    logical, intent(in) :: &
      l_imp_sfc_momentum_flux  ! Flag for implicit momentum surface fluxes.

    type (stats_metadata_type), intent(in) :: &
      stats_metadata

    !---------------------- InOut variables ----------------------
    type (stats), target, intent(inout) :: &
      stats_zt

    !---------------------- Local variables ----------------------
    integer :: k, kp1, km1 ! Array indices
    
    real( kind = core_rknd ), dimension(nz) :: &
      imp_sfc_flux

    ! Budget indices
    integer :: ixm_ma, ixm_ta

    !---------------------- Begin Code ----------------------

    select case ( solve_type )
    case ( windm_edsclrm_um )
      ixm_ma = stats_metadata%ium_ma
      ixm_ta = stats_metadata%ium_ta

    case ( windm_edsclrm_vm )
      ixm_ma = stats_metadata%ivm_ma
      ixm_ta = stats_metadata%ivm_ta

    case default
      ixm_ma = 0
      ixm_ta = 0

    end select
    
    imp_sfc_flux(:) = zero
    
    if ( l_imp_sfc_momentum_flux ) then

      ! Statistics:  implicit contributions for um or vm.

      ! xm term ta is modified at level 2 to include the effects of the
      ! surface flux.  In this case, this effects the implicit portion of
      ! the term, which handles the main diagonal for the turbulent advection term 
      if ( stats_metadata%ium_ta + stats_metadata%ivm_ta > 0 ) then
        imp_sfc_flux(2) =  - invrs_rho_ds_zt(2) * invrs_dzt(2) &
                             * rho_ds_zm(1) * ( u_star_sqd / wind_speed(2) )
      endif

    endif ! l_imp_sfc_momentum_flux

    ! Finalize implicit contributions for xm

    do k = 2, nz-1, 1

      km1 = max( k-1, 2 )
      kp1 = min( k+1, nz )

      ! xm mean advection
      ! xm term ma is completely implicit; call stat_update_var_pt.
      call stat_update_var_pt( ixm_ma, k, & ! intent(in)
             - lhs_ma_zt(3,k) * xm(km1)   &
             - lhs_ma_zt(2,k) * xm(k)     &
             - lhs_ma_zt(1,k) * xm(kp1),  & ! intent(in)
              stats_zt )                    ! intent(inout)

      ! xm turbulent transport (implicit component)
      ! xm term ta has both implicit and explicit components;
      ! call stat_end_update_pt.
      call stat_end_update_pt( ixm_ta, k,               & ! intent(in)
             - 0.5_core_rknd * lhs_diff(3,k) * xm(km1)  &
             + ( - 0.5_core_rknd * lhs_diff(2,k)        &
                 + imp_sfc_flux(k) ) * xm(k)               &         
             - 0.5_core_rknd * lhs_diff(1,k) * xm(kp1), & ! intent(in) 
           stats_zt )                                     ! intent(inout)

    enddo


    ! Upper boundary conditions
    k   = nz
    km1 = max( k-1, 1 )

    ! xm mean advection
    ! xm term ma is completely implicit; call stat_update_var_pt.
    call stat_update_var_pt( ixm_ma, k, & ! intent(in)
           - lhs_ma_zt(3,k) * xm(km1)   &
           - lhs_ma_zt(2,k) * xm(k),    & ! intent(in)
            stats_zt )                    ! intent(inout)

    ! xm turbulent transport (implicit component)
    ! xm term ta has both implicit and explicit components;
    ! call stat_end_update_pt.
    call stat_end_update_pt( ixm_ta, k,               & ! intent(in)
           - 0.5_core_rknd * lhs_diff(3,k) * xm(km1)  &
           + ( - 0.5_core_rknd * lhs_diff(2,k)        &
               + imp_sfc_flux(k) ) * xm(k),              & ! intent(in)
           stats_zt )                                   ! intent(inout)


    return
  end subroutine windm_edsclrm_implicit_stats

  !=============================================================================
  subroutine compute_uv_tndcy( nz, ngrdcol, solve_type, &
                               fcor, perp_wind_m, perp_wind_g, &
                               xm_forcing, l_implemented, &
                               stats_metadata, & 
                               stats_zt, & 
                               xm_tndcy )

    ! Description:
    ! Computes the explicit tendency for the um and vm wind components.
    !
    ! The only explicit tendency that is involved in the d(um)/dt or d(vm)/dt
    ! equations is the Coriolis tendency.
    !
    ! The d(um)/dt equation contains the term:
    !
    ! - f * ( v_g - vm );
    !
    ! where f is the Coriolis parameter and v_g is the v component of the
    ! geostrophic wind.
    !
    ! Likewise, the d(vm)/dt equation contains the term:
    !
    ! + f * ( u_g - um );
    !
    ! where u_g is the u component of the geostrophic wind.
    !
    ! This term is treated completely explicitly.  The values of um, vm, u_g,
    ! and v_g are all found on the thermodynamic levels.
    !
    ! Wind forcing from the GCSS cases is also added here.
    !
    ! References:
    !-----------------------------------------------------------------------

    use grid_class, only: & 
        grid ! Type

    use stats_type_utilities, only: & 
        stat_update_var

    use stats_variables, only: &
        stats_metadata_type

    use clubb_precision, only: &
        core_rknd ! Variable(s)

    use stats_type, only: stats ! Type

    implicit none

    ! -------------------------- Input Variables --------------------------
    integer, intent(in) :: &
      nz, &
      ngrdcol
    
    integer, intent(in) ::  &
      solve_type      ! Description of what is being solved for

    real( kind = core_rknd ), dimension(ngrdcol), intent(in) ::  & 
      fcor            ! Coriolis parameter     [s^-1]

    real( kind = core_rknd ), dimension(ngrdcol,nz), intent(in) :: & 
      perp_wind_m,  & ! Perpendicular component of the mean wind (e.g. v, for the u-eqn) [m/s]
      perp_wind_g,  & ! Perpendicular component of the geostropic wind (e.g. vg)         [m/s]
      xm_forcing      ! Prescribed wind forcing                                          [m/s/s]

    logical, intent(in) :: & 
      l_implemented   ! Flag for CLUBB being implemented in a larger model.

    type (stats_metadata_type), intent(in) :: &
      stats_metadata
      
    ! -------------------------- InOut Variables --------------------------
    type (stats), target, dimension(ngrdcol), intent(inout) :: &
      stats_zt

    ! -------------------------- Output Variables --------------------------
    real( kind = core_rknd ), dimension(ngrdcol,nz), intent(out) ::  &
      xm_tndcy        ! xm tendency            [m/s^2]

    ! -------------------------- Local Variables --------------------------
    integer :: & 
      ixm_gf, & 
      ixm_cf, &
      ixm_f

    real( kind = core_rknd ), dimension(ngrdcol,nz) :: & 
      xm_gf, & 
      xm_cf
      
    integer :: i, k

    ! -------------------------- Begin Code --------------------------

    !$acc enter data create( xm_gf, xm_cf )

    ! Initialize variables to 0.
    xm_gf = 0.0_core_rknd
    xm_cf = 0.0_core_rknd
    xm_tndcy = 0.0_core_rknd

    if ( .not. l_implemented ) then
      ! Only compute the Coriolis term if the model is running on it's own,
      ! and is not part of a larger, host model.

      select case ( solve_type )

      case ( windm_edsclrm_um )

        ixm_gf = stats_metadata%ium_gf
        ixm_cf = stats_metadata%ium_cf
        ixm_f  = stats_metadata%ium_f
        
        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 2, nz
          do i = 1, ngrdcol
            xm_gf(i,k) = - fcor(i) * perp_wind_g(i,k)
          end do
        end do
        !$acc end parallel loop
        
        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 2, nz
          do i = 1, ngrdcol
            xm_cf(i,k) = fcor(i) * perp_wind_m(i,k)
          end do
        end do
        !$acc end parallel loop

      case ( windm_edsclrm_vm )

        ixm_gf = stats_metadata%ivm_gf
        ixm_cf = stats_metadata%ivm_cf
        ixm_f  = stats_metadata%ivm_f

        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 2, nz
          do i = 1, ngrdcol
            xm_gf(i,k) = fcor(i) * perp_wind_g(i,k)
          end do
        end do
        !$acc end parallel loop

        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 2, nz
          do i = 1, ngrdcol
            xm_cf(i,k) = -fcor(i) * perp_wind_m(i,k)
          end do
        end do
        !$acc end parallel loop

      case default

        ixm_gf = 0
        ixm_cf = 0
        ixm_f = 0

        !$acc parallel loop gang vector collapse(2) default(present)
        do k = 2, nz
          do i = 1, ngrdcol
            xm_gf(i,k) = 0._core_rknd
            xm_cf(i,k) = 0._core_rknd
          end do
        end do
        !$acc end parallel loop

      end select

      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz
        do i = 1, ngrdcol
          xm_tndcy(i,k) = xm_gf(i,k) + xm_cf(i,k) + xm_forcing(i,k)
        end do
      end do
      !$acc end parallel loop

      if ( stats_metadata%l_stats_samp ) then

        !$acc update host( xm_gf, xm_cf, xm_forcing )

        do i = 1, ngrdcol
          ! xm term gf is completely explicit; call stat_update_var.
          call stat_update_var( ixm_gf, xm_gf(i,:), & ! intent(in)
                                stats_zt(i) )         ! intent(inout)

          ! xm term cf is completely explicit; call stat_update_var.
          call stat_update_var( ixm_cf, xm_cf(i,:), & ! intent(in)
                                stats_zt(i) )         ! intent(inout)

          ! xm term F
          call stat_update_var( ixm_f, xm_forcing(i,:), & ! intent(in)
                                stats_zt(i) )             ! intent(inout)
        end do
      endif

    else   ! implemented in a host model.

      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz
        do i = 1, ngrdcol
          xm_tndcy(i,k) = 0.0_core_rknd
        end do
      end do
      !$acc end parallel loop

    endif

    !$acc exit data delete( xm_gf, xm_cf )

    return

  end subroutine compute_uv_tndcy

  !======================================================================================
  subroutine windm_edsclrm_lhs( nz, ngrdcol, gr, dt, &
                                lhs_ma_zt, lhs_diff, &
                                wind_speed, u_star_sqd,  &
                                rho_ds_zm, invrs_rho_ds_zt,  &
                                l_implemented, l_imp_sfc_momentum_flux,  &
                                lhs )
    ! Description:
    ! Calculate the implicit portion of the horizontal wind or eddy-scalar
    ! time-tendency equation.  See the description in subroutine
    ! windm_edsclrm_solve for more details.
    ! 
    ! Notes: 
    !   Lower Boundary:
    !       The lower boundary condition is a fixed-flux boundary condition, which
    !       gets added into the time-tendency equation at level 2.
    !       The value of xm(1) is located below the model surface and does not effect
    !       the rest of the model.  Since xm can be either a horizontal wind component
    !       or a generic eddy scalar quantity, the value of xm(1) is simply set to the
    !       value of xm(2) after the equation matrix has been solved.
    !
    !   --- THIS SUBROUTINE HAS BEEN OPTIMIZED ---
    !   Simple changes to this procedure may adversely affect computational speed
    !       - Gunther Huebler, Aug. 2018, clubb:ticket:834
    !----------------------------------------------------------------------------------

    use grid_class, only:  & 
        grid   ! Type

    use clubb_precision, only:  & 
        core_rknd ! Variable(s)

    implicit none

    ! ----------------------- Input Variables -----------------------
    integer, intent(in) :: &
      nz, &
      ngrdcol

    type (grid), target, intent(in) :: gr
    
    real( kind = core_rknd ), intent(in) :: & 
      dt                 ! Model timestep                             [s]
      
    real( kind = core_rknd ), intent(in), dimension(3,ngrdcol,nz) :: &
      lhs_diff, & ! LHS diffustion terms
      lhs_ma_zt   ! LHS mean advection terms

    real( kind = core_rknd ), dimension(ngrdcol,nz), intent(in) :: &
      wind_speed,      & ! wind speed; sqrt( u^2 + v^2 )              [m/s]
      rho_ds_zm,       & ! Dry, static density on momentum levels     [kg/m^3]
      invrs_rho_ds_zt    ! Inv. dry, static density at thermo. levels [m^3/kg]

    real( kind = core_rknd ), dimension(ngrdcol), intent(in) :: &
      u_star_sqd    ! Surface friction velocity, u_*, squared  [m/s]

    logical, intent(in) ::  & 
      l_implemented, & ! Flag for CLUBB being implemented in a larger model.
      l_imp_sfc_momentum_flux  ! Flag for implicit momentum surface fluxes.

    ! ----------------------- Output Variable -----------------------
    real( kind = core_rknd ), dimension(3,ngrdcol,nz), intent(out) :: &
      lhs           ! Implicit contributions to xm (tridiagonal matrix)

    ! ----------------------- Local Variables -----------------------
    real( kind = core_rknd ) :: &
        invrs_dt    ! Inverse of dt, 1/dt, used for computational efficiency
        
    integer :: k, i ! Loop variable
    
    ! ----------------------- Begin Code -----------------------

    ! Calculate coefs of eddy diffusivity and inverse of dt
    invrs_dt = 1.0_core_rknd / dt

    ! Set lower boundary, see notes
    !$acc parallel loop gang vector default(present)
    do i = 1, ngrdcol
      lhs(1,i,1) = 0.0_core_rknd
      lhs(2,i,1) = 1.0_core_rknd
      lhs(3,i,1) = 0.0_core_rknd
    end do
    !$acc end parallel loop

    ! Add terms to lhs
    !$acc parallel loop gang vector collapse(2) default(present)
    do k = 2, nz
      do i = 1, ngrdcol
        lhs(1,i,k) = 0.5_core_rknd * lhs_diff(1,i,k)

        lhs(2,i,k) = 0.5_core_rknd * lhs_diff(2,i,k)
        
        ! LHS time tendency.
        lhs(2,i,k) = lhs(2,i,k) + invrs_dt

        lhs(3,i,k) = 0.5_core_rknd * lhs_diff(3,i,k)
      end do
    end do
    !$acc end parallel loop

    ! LHS mean advection term.
    if ( .not. l_implemented ) then
      !$acc parallel loop gang vector collapse(2) default(present)
      do k = 2, nz-1
        do i = 1, ngrdcol
          lhs(1:3,i,k) = lhs(1:3,i,k) + lhs_ma_zt(:,i,k)
        end do
      end do
      !$acc end parallel loop

    endif

    if ( l_imp_sfc_momentum_flux ) then

      ! LHS momentum surface flux.
      !$acc parallel loop gang vector default(present)
      do i = 1, ngrdcol
        lhs(2,i,2) = lhs(2,i,2) + invrs_rho_ds_zt(i,2) * gr%invrs_dzt(i,2) &
                                  * rho_ds_zm(i,1) * ( u_star_sqd(i) / wind_speed(i,2) )
      end do
      !$acc end parallel loop
    end if ! l_imp_sfc_momentum_flux

    return

  end subroutine windm_edsclrm_lhs

  !=============================================================================
  subroutine windm_edsclrm_rhs( nz, ngrdcol, gr, solve_type, dt, &
                                lhs_diff, xm, xm_tndcy,  &
                                rho_ds_zm, invrs_rho_ds_zt,  &
                                l_imp_sfc_momentum_flux, xpwp_sfc, &
                                stats_metadata, &
                                stats_zt, &
                                rhs )
    ! Description:
    !   Calculate the explicit portion of the horizontal wind or eddy-scalar
    !   time-tendency equation.  See the description in subroutine
    !   windm_edsclrm_solve for more details.
    ! 
    ! References:
    !   None
    ! 
    ! Notes:
    !   The lower boundary condition needs to be applied here at level 2.
    !   The lower boundary condition is a "fixed flux" boundary condition.
    !   The coding is the same as for a zero-flux boundary condition, but with
    !   an extra term added on the right-hand side at the boundary level.  For
    !   the rest of the model code, a zero-flux boundary condition is applied
    !   at level 1, and thus subroutine diffusion_zt_lhs is set-up to do that.
    !   In order to apply the same boundary condition code here at level 2, an
    !   adjuster needs to be used to tell diffusion_zt_lhs to use the code at
    !   level 2 that it normally uses at level 1.
    ! 
    !   --- THIS SUBROUTINE HAS BEEN OPTIMIZED ---
    !   Simple changes to this procedure may adversely affect computational speed
    !       - Gunther Huebler, Aug. 2018, clubb:ticket:834
    !----------------------------------------------------------------------------------

    use clubb_precision, only:  & 
        core_rknd ! Variable(s)

    use diffusion, only:  & 
        diffusion_zt_lhs    ! Procedure(s)

    use stats_variables, only: &
        stats_metadata_type

    use stats_type_utilities, only: &
        stat_begin_update_pt,  & ! Procedure(s)
        stat_modify_pt

    use grid_class, only:  & 
        grid ! Type

    use stats_type, only: stats ! Type

    implicit none

    !------------------- Input Variables -------------------
    integer, intent(in) :: &
      nz, &
      ngrdcol
    
    type (grid), target, intent(in) :: &
      gr
    
    integer, intent(in) :: &
      solve_type ! Description of what is being solved for

    real( kind = core_rknd ), intent(in) :: & 
      dt                 ! Model timestep                             [s]
      
    real( kind = core_rknd ), dimension(3,ngrdcol,nz), intent(in) :: &
      lhs_diff   ! LHS diffustion terms

    real( kind = core_rknd ), dimension(ngrdcol,nz), intent(in) :: &
      xm,              & ! Eddy-scalar variable, xm (thermo. levels)  [units vary]
      xm_tndcy,        & ! The explicit time-tendency acting on xm    [units vary]
      rho_ds_zm,       & ! Dry, static density on momentum levels     [kg/m^3]
      invrs_rho_ds_zt    ! Inv. dry, static density at thermo. levels [m^3/kg]

    real( kind = core_rknd ), dimension(ngrdcol), intent(in) :: &
      xpwp_sfc     ! x'w' at the surface                              [units vary]

    logical, intent(in) :: &
      l_imp_sfc_momentum_flux  ! Flag for implicit momentum surface fluxes.

    type (stats_metadata_type), intent(in) :: &
      stats_metadata

    !------------------- Inout Variable -------------------
    type (stats), target, dimension(ngrdcol), intent(inout) :: &
      stats_zt

    !------------------- Output Variable -------------------
    real( kind = core_rknd ), dimension(ngrdcol,nz), intent(out) :: &
      rhs          ! Right-hand side (explicit) contributions.

    !------------------- Local Variables -------------------
    integer :: i, k    ! Loop variable

    real( kind = core_rknd ) :: invrs_dt

    integer :: ixm_ta

    !------------------- Begin Code -------------------

    invrs_dt = 1.0_core_rknd / dt   ! Precalculate 1.0/dt to avoid redoing the divide

    select case ( solve_type )
      case ( windm_edsclrm_um )
        ixm_ta = stats_metadata%ium_ta
      case ( windm_edsclrm_vm )
        ixm_ta = stats_metadata%ivm_ta
      case default  ! Eddy scalars
        ixm_ta = 0
    end select

    ! For purposes of the matrix equation, rhs(1) is simply set to 0.
    !$acc parallel loop gang vector default(present)
    do i = 1, ngrdcol
      rhs(i,1) = 0.0_core_rknd
    end do
    !$acc end parallel loop

    ! Lower boundary calculation
    !$acc parallel loop gang vector default(present)
    do i = 1, ngrdcol
      rhs(i,2) = 0.5_core_rknd  & 
                 * ( - lhs_diff(2,i,2) * xm(i,2)        &
                     - lhs_diff(1,i,2) * xm(i,3) )      &
                 + xm_tndcy(i,2)                        & ! RHS forcings
                 + invrs_dt * xm(i,2)                     ! RHS time tendency
    end do
    !$acc end parallel loop

    ! Non-boundary rhs calculation, this is a highly vectorized loop
    !$acc parallel loop gang vector collapse(2) default(present)
    do k = 3, nz-1
      do i = 1, ngrdcol
        rhs(i,k) = 0.5_core_rknd  & 
                   * ( - lhs_diff(3,i,k) * xm(i,k-1)      &
                       - lhs_diff(2,i,k) * xm(i,k)        &
                       - lhs_diff(1,i,k) * xm(i,k+1) )    &
                   + xm_tndcy(i,k)                        & ! RHS forcings
                   + invrs_dt * xm(i,k)                     ! RHS time tendency
      end do
    end do
    !$acc end parallel loop

    ! Upper boundary calculation
    !$acc parallel loop gang vector default(present)
    do i = 1, ngrdcol
      rhs(i,nz) = 0.5_core_rknd  & 
                  * ( - lhs_diff(3,i,nz) * xm(i,nz-1)  &
                      - lhs_diff(2,i,nz) * xm(i,nz) )  &
                  + xm_tndcy(i,nz)                     & ! RHS forcings
                  + invrs_dt * xm(i,nz)                  ! RHS time tendency
    end do
    !$acc end parallel loop

    if ( stats_metadata%l_stats_samp .and. ixm_ta > 0 ) then

      !$acc update host( lhs_diff, xm )
      
      do i = 1, ngrdcol

        ! Statistics:  explicit contributions for um or vm.

        ! xm term ta has both implicit and explicit components; call
        ! stat_begin_update_pt.  Since stat_begin_update_pt automatically
        ! subtracts the value sent in, reverse the sign on right-hand side
        ! turbulent advection component.

        ! Lower boundary
        call stat_begin_update_pt( ixm_ta, 2, &                         ! intent(in)
                                   0.5_core_rknd  &
                                 * ( lhs_diff(2,i,2) * xm(i,2)   &      ! intent(in)
                                 +   lhs_diff(1,i,2) * xm(i,3) ), &
                                     stats_zt(i) )                      ! intent(inout)

        do k = 3, nz-1
          
          call stat_begin_update_pt( ixm_ta, k, &                         ! intent(in)
                                     0.5_core_rknd  &
                                   * ( lhs_diff(3,i,k) * xm(i,k-1) &
                                   +   lhs_diff(2,i,k) * xm(i,k)   &      ! intent(in)
                                   +   lhs_diff(1,i,k) * xm(i,k+1) ), &
                                       stats_zt(i) )                      ! intent(inout)
        end do

        ! Upper boundary
        call stat_begin_update_pt( ixm_ta, nz, &
                                   0.5_core_rknd  &                       ! intent(in)
                                 * ( lhs_diff(3,i,nz) * xm(i,nz-1) &
                                 +   lhs_diff(2,i,nz) * xm(i,nz) ), &     ! intent(in)
                                     stats_zt(i) )                        ! intent(inout)
      end do
    endif

    if ( .not. l_imp_sfc_momentum_flux ) then

      ! RHS generalized surface flux.
      !$acc parallel loop gang vector default(present)
      do i = 1, ngrdcol
        rhs(i,2) = rhs(i,2) + invrs_rho_ds_zt(i,2)  &
                              * gr%invrs_dzt(i,2)  &
                              * rho_ds_zm(i,1) * xpwp_sfc(i)
      end do
      !$acc end parallel loop

      if ( stats_metadata%l_stats_samp .and. ixm_ta > 0 ) then

        !$acc update host( invrs_rho_ds_zt, rho_ds_zm, xpwp_sfc )
      
        do i = 1, ngrdcol
          call stat_modify_pt( ixm_ta, 2,  &                    ! intent(in)  
                             + invrs_rho_ds_zt(i,2)  &  
                             * gr%invrs_dzt(i,2)  &
                             * rho_ds_zm(i,1) * xpwp_sfc(i),  & ! intent(in)
                               stats_zt(i) )                    ! intent(inout)
        end do
      end if

    endif ! l_imp_sfc_momentum_flux

    return

  end subroutine windm_edsclrm_rhs

end module advance_windm_edsclrm_module
