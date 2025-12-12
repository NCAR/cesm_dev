!
!
!  This module contains the subroutines required to fracture sea ice
!  by ocean surface waves
!
!  Theory based on:
!
!  !REF! Tremblay 
!
!  This module solves a conservation of momentum equation for a 
!  thin elastic plate in hydrostatic equilibrium. The FSD is 
!  updated according to the fracture lengths computed for a floe
!  in each floe size category
!

     module icepack_wavefracspec_alt

      use icepack_kinds
      use icepack_parameters, only: p01, p5, c0, c1, c2, c3, c4, c10
      use icepack_parameters, only: bignum, puny, gravit, pi, rhow, rhoi
      use icepack_tracers, only: nt_fsd, ncat, nfsd
      use icepack_warnings, only: warnstr, icepack_warnings_add,  icepack_warnings_aborted
      use icepack_fsd

      implicit none
      private
      public :: icepack_step_wavefracture_alt

      real (kind=dbl_kind), parameter  :: &
         young_mod  = 10e9, &          ! Youngs Modulus for ice (Pa)
         straincrit = 3.e-5_dbl_kind, & ! critical strain
         dx = c4 !0.5_dbl_kind ! domain spacing (m)

!=======================================================================

      contains


!=======================================================================
!autodocument_start icepack_step_wavefracture
!
!  Given fracture histogram computed from local wave spectrum, evolve
!  the floe size distribution
!
!  authors: 2018 Lettie Roach, NIWA/VUW
!           2024 Lettie Roach, Columbia/NASA GISS - updates for new scheme
!
      subroutine icepack_step_wavefracture_alt(wave_spec_type,   &
                  dt,                                        &
                  nfreq,                                     &
                  aice,          vice,            aicen,     &
                  wave_spectrum, wavefreq,        dwavefreq, &
                  trcrn,         d_afsd_wave)


      character (len=char_len), intent(in) :: &
         wave_spec_type   ! type of wave spectrum forcing

      integer (kind=int_kind), intent(in) :: &
         nfreq            ! number of wave frequency categories

      real (kind=dbl_kind), intent(in) :: &
         dt,           & ! time step
         aice,         & ! ice area fraction
         vice            ! ice volume per unit area

      real (kind=dbl_kind), dimension(ncat), intent(in) :: &
         aicen           ! ice area fraction (categories)

      real (kind=dbl_kind), dimension (:), intent(in) :: &
         wavefreq,     & ! wave frequencies (s^-1)
         dwavefreq       ! wave frequency bin widths (s^-1)

      real (kind=dbl_kind), dimension(:), intent(inout) :: &
         wave_spectrum   ! ocean surface wave spectrum as a function of frequency
                         ! power spectral density of surface elevation, E(f) (units m^2 s)

      real (kind=dbl_kind), dimension(:,:), intent(inout) :: &
         trcrn           ! tracer array

      real (kind=dbl_kind), dimension(:), intent(out) :: &
         d_afsd_wave     ! change in fsd due to waves

      real (kind=dbl_kind), dimension(nfsd,ncat) :: &
         d_afsdn_wave    ! change in fsd due to waves, per category

!autodocument_end
      ! local variables
      integer (kind=int_kind) :: &
         n, k,  &
         nsubt ! number of subcycles

      real (kind=dbl_kind), dimension (nfsd, nfsd) :: &
         frac, fracture_hist

      real (kind=dbl_kind) :: &
         hbar         , & ! mean ice thickness
         elapsed_t    , & ! elapsed subcycling time
         subdt        , & ! subcycling time step
         cons_error       ! area conservation error

      real (kind=dbl_kind), dimension (nfsd) :: &
         omega, loss, gain, &
         afsd_init    , & ! tracer array
         afsd_tmp     , & ! tracer array
         d_afsd_tmp       ! change
   character(len=*),parameter :: &
         subname='(icepack_step_wavefracture_alt)'


      !------------------------------------

      ! initialize
      d_afsd_wave    (:)   = c0
      d_afsdn_wave   (:,:) = c0
      fracture_hist  (:,:)   = c0

      ! if all ice is not in first floe size category
      if (.NOT. ALL(trcrn(nt_fsd,:).ge.c1-puny)) then
      if ((aice > p01).and.(MAXVAL(wave_spectrum(:)) > puny)) then

          hbar = vice/aice ! note- average thickness
          DO k = 2, nfsd
              ! if this floe size class (avg across thickness) has ice
              if (SUM(trcrn(nt_fsd+k-1,:))/ncat.gt.puny) then
                  call solve_yt_for_strain(nfsd, nfreq, & 
                               floe_rad_l, floe_rad_c, &
                               wavefreq, dwavefreq, &
                               c2*floe_rad_c(k), &
                               hbar, wave_spectrum, & 
                               fracture_hist(k,:))
              end if          
          END DO
          if (MAXVAL(fracture_hist) > puny) then
            ! protect against small numerical errors
            call icepack_cleanup_fsd ( trcrn(nt_fsd:nt_fsd+nfsd-1,:) )
            if (icepack_warnings_aborted(subname)) return

             DO n = 1, ncat

              afsd_init(:) = trcrn(nt_fsd:nt_fsd+nfsd-1,n)

              ! if there is ice, and a FSD, and not all ice is the smallest floe size
              if ((aicen(n) > puny) .and. (SUM(afsd_init(:)) > puny) &
                                    .and.     (afsd_init(1) < c1)) then

                  afsd_tmp =  afsd_init
                  loss(:) = c0
                  gain(:) = c0
                  omega(:) = c0
                  DO k = 1, nfsd
                      omega(k) = afsd_tmp(k)*SUM(fracture_hist(k,1:k))
                      loss(k) = omega(k)
                  END DO

                  DO k = 1, nfsd
                      gain(k) = SUM(omega(:)*fracture_hist(:,k))
                  END DO
                  afsd_tmp = afsd_tmp + gain -loss

                  ! update trcrn
                  trcrn(nt_fsd:nt_fsd+nfsd-1,n) = afsd_tmp/SUM(afsd_tmp)
                  call icepack_cleanup_fsd ( trcrn(nt_fsd:nt_fsd+nfsd-1,:) )
                  if (icepack_warnings_aborted(subname)) return

                  ! for diagnostics
                  d_afsdn_wave(:,n) = afsd_tmp(:) - afsd_init(:)
                  d_afsd_wave (:)   = d_afsd_wave(:) + aicen(n)*d_afsdn_wave(:,n)
 
              end if
             END DO

      end if
      end if
      end if

      end subroutine icepack_step_wavefracture_alt


!===========================================================================
!
      subroutine alt_get_fraclengths(nfsd, floe_rad_c, floe_rad_l, &
                            x, strain, frac_local)
! 
!     Given 1D strain field (with varying size) locate points that exceed 
!     a critical strain. If critical strain is exceeded for multiple points
!     in a continuous segment, save the largest value. Compute the distances
!     between these points, and bin them into the floe size categories

!     authors: 2024 Lettie Roach Columbia/NASA GISS

      integer (kind=int_kind), intent(in) :: &
          nfsd

      real (kind=dbl_kind), dimension(:), intent(in) :: &
          x, strain, floe_rad_c, floe_rad_l

      real(kind=dbl_kind), dimension(:), intent(inout) :: &
          frac_local ! binned histogram of fractures

      ! local
      logical (kind=log_kind), dimension (:), allocatable :: &
          exceed_crit_pos, &
          exceed_crit_neg

      integer (kind=int_kind), dimension(:), allocatable :: &
          extremelocs !minlocs, maxlocs

      real (kind = dbl_kind), dimension(:), allocatable :: &
          fraclengths

      integer (kind=int_kind) :: &
        nx, n_exceed, j_beg, j_end, j, jj, k, nfrac
 

      nx = SIZE(strain)
      allocate(exceed_crit_pos (nx))
      allocate(exceed_crit_neg (nx))
      exceed_crit_pos(:) = .false.
      exceed_crit_neg(:) = .false.

      WHERE (strain.gt.straincrit) exceed_crit_pos = .true.
      WHERE (strain.lt.-straincrit) exceed_crit_neg = .true.
      n_exceed = COUNT(exceed_crit_pos) + COUNT(exceed_crit_neg)
      allocate(extremelocs(n_exceed))
      extremelocs(:) = c0

      j_beg = 0
      j_end = 0
      j = 1
      k = 0
      DO WHILE (j<nx)
          if (exceed_crit_neg(j)) then
              j_beg = j
              j_end = j

              DO jj = 1, nx-j
                  if (exceed_crit_neg(j+jj)) then
                      j_end = j+jj
                  else
                      EXIT
                  end if
              END DO
              k = k + 1
              extremelocs(k) = MINLOC(strain(j_beg:j_end),DIM=1)+j_beg-1
              j = j_end + 1 ! skip to end of segment
          else if (exceed_crit_pos(j)) then
              j_beg = j
              j_end = j

              DO jj = 1, nx-j
                  if (exceed_crit_pos(j+jj)) then
                      j_end = j+jj
                  else
                      EXIT
                  end if
              END DO
              k = k + 1
              extremelocs(k) = MAXLOC(strain(j_beg:j_end),DIM=1)+j_beg-1
              j = j_end + 1 ! skip to end of segment

          else
              j = j + 1 ! move to next point
          end if

      END DO

      nfrac = COUNT(extremelocs>0)
      allocate(fraclengths(nfrac+1))

      if (nfrac.eq.0) then
             fraclengths(:) = c0
      else 
      fraclengths(1) = X(extremelocs(1)) - X(1) 
      do k = 2, nfrac
          fraclengths(k) = X(extremelocs(k)) - X(extremelocs(k-1))
      end do
      fraclengths(nfrac+1) = X(nx) - X(extremelocs(nfrac))
      end if
      frac_local(:) = c0

      ! convert from diameter to radii
      fraclengths(:) = fraclengths(:)/c2

      if (.not. ALL(fraclengths.lt.floe_rad_l(1))) then
          ! bin into FS cats
          do j = 1, size(fraclengths)
              if (fraclengths(j).gt.floe_rad_l(1)) then
                   do k = 1, nfsd-1
                       if ((fraclengths(j) >= floe_rad_l(k)) .and. &
                        (fraclengths(j) < floe_rad_l(k+1))) then
                            frac_local(k) = frac_local(k) + 1
                       end if
                   end do
                if (fraclengths(j)>floe_rad_l(nfsd)) frac_local(nfsd) = frac_local(nfsd) + 1
              end if
          end do

          do k = 1, nfsd
               frac_local(k) = floe_rad_c(k)*frac_local(k)
          end do

          ! normalize
          if (SUM(frac_local) > puny) frac_local(:) = frac_local(:) / SUM(frac_local(:))

      end if


      end subroutine alt_get_fraclengths

!===========================================================================
!
!  For an ice plate of length L in hydrostatic equilibrium at the ocean surface,
!  given a sea surface height field (with random phase), we obtain a fourth-order
!  inhomogeneous ordinary differential equation describing a simple high pass 
!  filter.
!
!  authors 2024: Bruno Tremblay, McGill 
!                implemented in Fortran by Lettie Roach

      subroutine solve_yt_for_strain(nfsd, nfreq, &
                                     floe_rad_l, floe_rad_c, &
                                     wavefreq, dwavefreq, &
                                     L, hbar, spec_efreq, &
                                     frac_local)
     
      external dgesv ! LAPACK matrix solver

      integer(kind=int_kind), intent(in) :: &
           nfreq, & ! number of wave frequencies
           nfsd     ! number of floe size categories

      real (kind = dbl_kind), intent (in) :: &
           L, & ! floe diameter (m)
           hbar ! floe thickness (m)

      real (kind=dbl_kind), dimension (:), intent(in) :: &
         wavefreq,   & ! wave frequencies (s^-1)
         dwavefreq,  & ! wave frequency bin widths (s^-1)
         spec_efreq, & ! wave spectrum (m^2 s)
         floe_rad_c, & ! floe radius center (m)
         floe_rad_l    ! floe radius lower bin edge (m)


      real (kind=dbl_kind), dimension(:), intent(inout) :: &
           frac_local

      real (kind=dbl_kind), dimension(:),allocatable :: &
           strain, strain_yP

      ! local variables
      integer (kind = int_kind) :: &
           Lint, nx, & ! length, number of points in domain
           j, nseed, n, & ! index
           info, ipiv(4) ! variables for LAPACK matrix solver

      real (kind = dbl_kind), dimension (:), allocatable :: &
           x, xp,  & ! spatial domain 
           !yH, yP, &  ! homogenous and particular SSH solution
           yppH, yppP, & ! second deriv SSH for each solution
           ypp           ! second deriv SSH for total solution

      real (kind = dbl_kind) :: &
           I, & ! moment of inertia [m^3]
           Lambda, & ! characteristic length scale [m]
           gamm, &   ! non-dimensional number
           m, b, ap, bp

       real (kind = dbl_kind), dimension(nfreq) :: &
           lamdai, &  ! wavelengths [m]
           spec_coeff, & ! spectral coefficients
           langi, &  ! rescaled wavelength
           AAmi, &      ! rescaled spectral coefficients
           PHIi         ! phase for SSH

       real (kind=dbl_kind), dimension(4,4) :: &
           aa ! 4x4 matrix

       real (kind=dbl_kind), dimension(4) :: &
           bb, cc_alt, cc ! column vectors

       real (kind=dbl_kind), dimension(:,:), allocatable :: &
           arg

       integer, dimension(:), allocatable :: iseed

       Lint = NINT(L)
       nx = NINT(Lint/dx+dx)  
       allocate(x(nx))
       allocate(xp(nx))
       !allocate(yP(nx))
       !allocate(yH(nx))
       allocate(ypp(nx))
       allocate(strain(nx))
       allocate(strain_yP(nx))


       ! dispersion relation
       lamdai (:) = gravit/(c2*pi*wavefreq (:)**2)

       ! spectral coefficients
       spec_coeff = sqrt(c2*spec_efreq*dwavefreq)
       
       ! spatial discretization
       DO j=1,nx
           x(j) = -Lint/c2 + (j-1)*dx
       END DO

       ! this should be the same each run
       ! and for restarts

       call random_seed(size=nseed)
       allocate(iseed(nseed))
       do n=1,nseed
          iseed(n) = nint(hbar*real(n,kind=dbl_kind)*1000.d0-hbar*real(n,kind=dbl_kind)*100.d0)
       enddo

       ! Initialize seed based on the thickness field.
       call random_seed(put=iseed)
       CALL RANDOM_NUMBER(PHIi)
       PHIi = c2*pi*PHIi

       I=hbar**3/12
       Lambda = (young_mod*I/(rhow*gravit))**(0.25_dbl_kind)

       gamm = L/(c2*SQRT(c2)*Lambda)
       langi = lamdai/(c2*pi)
       AAmi = spec_coeff*langi**4/(Lambda**4 + langi**4)
       xp = x/(SQRT(c2)*Lambda)

       ! floating line
       m = 6./(L**2)*SUM(spec_coeff*lamdai/pi*sin(PHIi)*(-cos(pi*L/lamdai)+lamdai/(pi*L)*sin(pi*L/lamdai)))
       b = (c1/L)*SUM(spec_coeff*lamdai/pi*sin(pi*L/lamdai)*cos(PHIi))- rhoi/rhow*hbar
       bp = -b - rhoi/rhow*hbar
       ap = -m

       ! only compute homogeneous solution for floes
       ! less than 300m in diameter
       if (L.le.300._dbl_kind) then

           aa(1,1) = EXP(-gamm)*SIN(gamm)
           aa(1,2) = EXP(-gamm)*COS(gamm)
           aa(1,3) = -EXP(gamm)*SIN(gamm)
           aa(1,4) = -EXP(gamm)*COS(gamm)

           aa(2,1) = -EXP(gamm)*SIN(gamm)
           aa(2,2) = EXP(gamm)*COS(gamm)
           aa(2,3) = EXP(-gamm)*SIN(gamm)
           aa(2,4) = -EXP(-gamm)*COS(gamm)

           aa(3,1) = SIN(gamm)*COSH(gamm) + COS(gamm)*SINH(gamm)
           aa(3,2) = -COS(gamm)*SINH(gamm) + SIN(gamm)*COSH(gamm)
           aa(3,3) = SIN(gamm)*COSH(gamm) + COS(gamm)*SINH(gamm)
           aa(3,4) = -SIN(gamm)*COSH(gamm) + COS(gamm)*SINH(gamm)

           aa(4,1) = gamm*SIN(gamm)*SINH(gamm) + gamm*COS(gamm)*COSH(gamm) - SIN(gamm)*COSH(gamm)
           aa(4,2) = gamm*SIN(gamm)*SINH(gamm) - gamm*COS(gamm)*COSH(gamm) + COS(gamm)*SINH(gamm)
           aa(4,3) = -gamm*COS(gamm)*COSH(gamm) - gamm*SIN(gamm)*SINH(gamm) + SIN(gamm)*COSH(gamm)
           aa(4,4) = -gamm*COS(gamm)*COSH(gamm) + gamm*SIN(gamm)*SINH(gamm) + COS(gamm)*SINH(gamm)

           bb(1) = Lambda**2*SUM(AAmi/(langi**2)*COS(L/(c2*langi)+PHIi))
           bb(2) = Lambda**2*SUM(AAmi/(langi**2)*COS(L/(c2*langi)-PHIi))
       
           bb(3) = - SQRT(c2)/(c2*Lambda)*(SUM(AAmi*langi* ( SIN(L/(c2*langi)-PHIi) +&
               SIN(L/(c2*langi)+PHIi) )) + bp*L)

           bb(4) = - c1/(c2*Lambda**2)*(SUM(AAmi*langi* &
               ( L/c2*(SIN(L/(c2*langi)-PHIi) - SIN(L/(c2*langi)+PHIi)) + &
                 langi*(COS(L/(c2*langi)-PHIi) - COS(L/(c2*langi)+PHIi)))) + ap*L**3/12)

           ! matrix solver
           ipiv(:) = c0
           call DGESV (4, 1, aa, 4, ipiv, cc, 4, info)
           if (info/=0) then
               print *, ' -- LAPACK DGESV return error code: ',info
           end if
    
           ! homogenous solution
           !yH = EXP(xp)*(cc(1)*COS(xp)+cc(2)*SIN(xp)) + EXP(-xp)*(cc(3)*COS(xp)+cc(4)*SIN(xp))
           yppH = (EXP(xp)*(-cc(1)*SIN(xp)+cc(2)*COS(xp)) - EXP(-xp)*(-cc(3)*SIN(xp)+cc(4)*COS(xp)))/Lambda**2

       end if ! L less than 300m

       allocate(arg(nfreq,nx))
       DO j=1,nx
           arg(:,j) = x(j)/langi(:) - PHIi(:)
       END DO

       ! compute particular solution
       !yP = MATMUL(AAmi,COS(arg))+(ap*x+bp)
       yppP = -MATMUL(AAmi/langi**2,COS(arg))

       strain_yP = hbar*yppP/c2

       ! only consider particular solution for floes>300m
       if (L.gt.300_dbl_kind) then
           strain = strain_yP
       else
           ypp = yppP + yppH
           strain = hbar*ypp/c2
       end if

       ! if strains are large, find fracture length histogram
       frac_local(:) = c0
       if (MAXVAL(ABS(strain)).gt.straincrit) then
           call alt_get_fraclengths(nfsd, floe_rad_c, floe_rad_l, &
                                    x,strain, frac_local)
       end if


       end subroutine solve_yt_for_strain

!=======================================================================


!=======================================================================

      end module icepack_wavefracspec_alt

!=======================================================================


