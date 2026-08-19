# CSLAM qdel4 configuration as SourceMods for stock cam_development

Drop all 14 *.F90 files into `SourceMods/src.cam/` of a case built from
ESCOMP/cam_development at tag **cam6_4_195** (or later, if they still apply).

Reproduces the preferred CSLAM Q-noise configuration from branch
`qfilter_on_jul01` @ 308f0c11 (PeterHjortLauritzen/CAM):

- CSLAM-grid mass-conservative del4 filter on tracers, nu = nu_p,
  precomputed conservative face weights, cross-diffusion (xdiff) correction,
  FCT limiter, slim 1-ring halo buffer (runtime logical `cslam_q_filter`,
  default .true.)
- del4 damping of qdp (water vapor) on GLL after cslam2gll with
  nu_q_cslam = 0.5*nu_p and automatic subcycling (nsub from CFL in
  print_cfl; 2 at ne30, 1 at ne120)
- sponge nu_dp uninitialized-variable fix

NOT included (cannot ride in SourceMods): the branch also removes some
`se_sponge_del4_*` defaults for ht/xt/WACCM configs in
`bld/namelist_files/namelist_defaults_cam.xml`. This is a confirmed no-op
for MT low-top compsets (e.g. FHISTC_MTso: all three resolve to -1 either
way) but matters for ht/xt/WACCM runs — do not use this package for those
without also patching the XML.

Validated 2026-08-12: cam6_4_195 + these files vs the branch build,
1-day FHISTC_MTso ne30pg3_ne30pg3_mg17, atm.log state prints
(se_statefreq, se_statediag_numtrac=200) bit-identical.
