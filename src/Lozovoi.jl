# Lozovoi.jl - parameters from 
# Universal tight binding model for chemical reactions in solution and at surfaces. II. Water
# A. Y. Lozovoi1, T. J. Sheppard1, D. L. Pashov2, J. J. Kohanoff1, and A. T. Paxton2, a)
# The Journal of Chemical Physics 141, 044504 (2014);
# https://doi.org/10.1063/1.4890343

# Table I above

# First column, O-H
OHAssσ =-0.5018

OHApsσ = -0.4362

OHnssσ = 2.0963
OHnpsσ = 1.5019

OHnc = 4.0561
OHr0 = 1.8094
OHrc = 3.7985

# macro GSP(A,n,nc,r0,rc)

OHVssσ=@GSP(OHAssσ,OHnssσ,OHnc,OHr0,OHrc)
OHVpsσ=@GSP(OHApsσ,OHnpsσ,OHnc,OHr0,OHrc)

# Second column, O-O
OOAssσ = -0.0150
OOAspσ = +0.0020
OOApsσ = -0.0020
OOAppσ = +0.0500
OOAppπ = -0.0200

OOnssσ = 2
OOnspσ = 2
OOnpsσ = 2
OOnppσ = 3
OOnppπ = 3

OOnc = 6
OOr0 = 5.6
OOrc = 9.0

OOVssσ=@GSP(OOAssσ,OOnssσ,OOnc,OOr0,OOrc)
OOVspσ=@GSP(OOAspσ,OOnspσ,OOnc,OOr0,OOrc)
OOVpsσ=@GSP(OOApsσ,OOnpsσ,OOnc,OOr0,OOrc)
OOVppσ=@GSP(OOAppσ,OOnppσ,OOnc,OOr0,OOrc)
OOVppπ=@GSP(OOAppπ,OOnppπ,OOnc,OOr0,OOrc)

# Pair potentials

OHϕ0 = 0.73669
OHn = 3.3502
OHnc = 6.3096
OHr0 = 1.8094
OHrc = 3.3550

OHPP = @GSP(OHϕ0,OHn,OHnc,OHr0,OHrc)

OOr0 = 5.6
OOϕ1 = 4.0306e-3
OOϕ2 = -2.0265e-3
OOm1 = 10
OOm2 = 6
OOp1 = 0
OOp2 = 0

OOPP = @EPL(OOr0,(OOϕ1,OOϕ2),(OOm1,OOm2),(OOp1,OOp2))

