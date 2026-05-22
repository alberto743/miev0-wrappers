! SPDX-FileCopyrightText: 2026 Alberto P
!
! SPDX-License-Identifier: MPL-2.0

program mieleg
use iso_fortran_env, only: real64
implicit none(type, external)
external :: miev0

real(kind=real64), parameter :: pi = 3.141592653589793_real64
integer, parameter :: maxang = 1000001
integer, parameter :: momdim = 4000
#ifndef NDEBUG
logical, parameter :: prnt(2) = [.false., .true.]
#else
logical, parameter :: prnt(2) = [.false., .false.]
#endif
logical :: perfct = .false.
logical :: anyang = .false.
real :: mimcut = 1.e-6
integer, parameter :: ipol = 1
integer :: ipolzn = 0
integer, parameter :: nrefin = 1
integer, parameter :: iszpar = 1
integer, parameter :: iang = 1
integer :: numang = 1000001
integer :: step


real :: qext, qsca, gqsc, spike
real :: pmom(0:momdim, 4)
complex :: sforw, sback
complex :: s1(maxang), s2(maxang), tforw(2), tback(2)

integer :: num_args
character(len=32) :: arg
real :: arg_real

integer :: i, n
integer :: errstat

real :: params(4)
real :: mr, mi, rad, lam
complex :: crefin

real :: xx
integer :: nmom
real :: xmu(maxang)
real :: fnorm


num_args = command_argument_count()
if (num_args /= 4) then
    write(*, *) "Usage: mieleg <mr> <mi> <rad> <lam>"
    stop 1
end if

do i = 1, command_argument_count()
    call get_command_argument(i, arg)
    read(arg, *, iostat=errstat) arg_real
    if (errstat /= 0) then
        write(*, *) "Error: Argument is not a valid real number."
        stop 2
    end if
    params(i) = real(arg_real)
end do
mr = params(1)
mi = params(2)
crefin = cmplx(mr, mi)
rad = params(3)
lam = params(4)

#ifndef NDEBUG
print *, ">> Input parameters:"
print *, ">>  Real part of refractive index (mr): ", mr
print *, ">>  Imaginary part of refractive index (mi): ", mi
print *, ">>  Particle radius (rad): ", rad
print *, ">>  Wavelength (lam): ", lam
#endif

xx = 2 * pi * rad/lam

step = 2 / (numang - 1)
nmom = int(2 * (xx + 4 * xx**(1._real64/3._real64) + 2))
#ifndef NDEBUG
print *, ">> Size parameter (xx): ", xx
print *, ">> Number of moments (nmom): ", nmom
#endif
do n = 1, numang
   xmu(n) = 1 - (n - 1)*step
end do

call MIEV0(xx, crefin, perfct, mimcut, anyang,       &
           numang, xmu, nmom, ipolzn, momdim, prnt,  &
           qext, qsca, gqsc, pmom, sforw, sback, s1, &
           s2, tforw, tback, spike)

fnorm  = 4._real64 / (xx**2 * qsca)

#ifndef NDEBUG
print *, ">> qext: ", qext
print *, ">> qsca: ", qsca
print *, ">> gqsc: ", gqsc
print *, ">> fnorm: ", fnorm
#endif

write(*, fmt="(a)") "{"
write(*, fmt="(a,es15.8,a)") '  "extinction_efficiency": ', qext, ','
write(*, fmt="(a,es15.8,a)") '  "scattering_efficiency": ', qsca, ','
write(*, fmt="(a,es15.8,a)") '  "sphere_geometric_cross_section": ', pi * rad**2, ','
write(*, fmt="(a,es15.8,a)") '  "single_scattering_albedo": ', qsca/qext, ','
write(*, fmt="(a,es15.8,a)") '  "asymmetry_factor": ', gqsc/qsca, ','

write(*, fmt="(a)") '  "legendre_moments": ['
do i = 0, nmom-1
#ifndef NDEBUG
    write(*, fmt="(a,i4,1x,es15.8,1x,es15.8,1x,es15.8)") '>> ', i, pmom(i,1), fnorm * pmom(i,1), (2._real64*i+1._real64)/2._real64 * fnorm * pmom(i,1)
#endif
    write(*, fmt="(a,es15.8,a)") '    ', fnorm * pmom(i,1), ','
end do
#ifndef NDEBUG
write(*, fmt="(a,i4,1x,es15.8,1x,es15.8,1x,es15.8)") '>> ', i, pmom(nmom,1), fnorm * pmom(nmom,1), (2._real64*i+1._real64)/2._real64 * fnorm * pmom(nmom,1)
#endif
write(*, fmt="(a,es15.8,a)") '    ', fnorm * pmom(nmom,1)
write(*, fmt="(a)") '  ]'
write(*, fmt="(a)") '}'

end program mieleg
