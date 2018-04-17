# Zinc Blend - test

A="Ga"
C="As" # Old friend

const hbarsquaredbym = 7.62 # eV.Å^2

V(eta,d)=eta*hbarsquaredbym/d^2

# See page 76 - simple tetrahedral
# ηssσ, ηspσ, ηppσ, ηppπ

# Covalent, apparently, with GaAs
d=SST[AtoZ[A]].rc + SST[AtoZ[C]].rc
println("Distance: $d")

H=HarrisonIME # using traditional Harrison site params

# p 76, left hand side
Ess=V(H.ηssσ,d)
Esp=-V(H.ηspσ,d)/3^(1/2)
Exx=1/3*V(H.ηppσ,d) + 2/3*V(H.ηppπ,d)
Exy=1/3*V(H.ηppσ,d) - 1/3*V(H.ηppπ,d)

const ϵsc = -SST[AtoZ[C]].ϵs
const ϵsa = -SST[AtoZ[A]].ϵs
const ϵpc = -SST[AtoZ[C]].ϵp
const ϵpa = -SST[AtoZ[A]].ϵp

# Gamma point for now; e^0 = 1
a=d

d1=[ 1  1  1]'*a/4
d2=[ 1 -1 -1]'*a/4
d3=[-1  1 -1]'*a/4
d4=[-1 -1  1]'*a/4

# This is a terrible function currently; not very hygenic at all
function bandsfork(k)
# shorthand... I think as used in Wannier's solid state book?
ixp(f)=exp(im*f)

g0=ixp(k⋅d1) + ixp(k⋅d2) + ixp(k⋅d3) + ixp(k⋅d4)
g1=ixp(k⋅d1) + ixp(k⋅d2) - ixp(k⋅d3) - ixp(k⋅d4)
g2=ixp(k⋅d1) - ixp(k⋅d2) + ixp(k⋅d3) - ixp(k⋅d4)
g3=ixp(k⋅d1) - ixp(k⋅d2) - ixp(k⋅d3) + ixp(k⋅d4)

# Gamma point only...
#g0=1.0
#g1=1.0
#g2=1.0
#g3=1.0

g0s=conj(g0)
g1s=conj(g1)
g2s=conj(g2)
g3s=conj(g3)

# Table 3--1, p. 77
LCAOH= [
ϵsc       Ess*g0  0        0        0        Esp*g1  Esp*g2  Esp*g3 ;
Ess*g0    ϵsa    -Esp*g1s -Esp*g2s -Esp*g3s  0       0       0      ;
0        -Esp*g1  ϵpc      0        0        Exx*g0  Exy*g3  Exy*g2 ;
0        -Esp*g2  0        ϵpc      0        Exy*g3  Exx*g0  Exy*g1 ;
0        -Esp*g3  0        0        ϵpc      Exy*g2  Exy*g1  Exx*g0 ;
Esp*g1s  0        Exx*g0s  Exy*g3s  Exy*g2s  ϵpa     0       0      ;
Esp*g2s  0        Exy*g3s  Exx*g0s  Exy*g1s  0       ϵpa     0      ;
Esp*g3s  0        Exy*g2s  Exy*g1s  Exx*g0s  0       0       ϵpa   ]

println("LCAOH matrix @ k=$k")
display(LCAOH)

println("Eigendecomposition")
display(eigvals(LCAOH)) # Do ya thing Liner Algebra!

return eigvals(LCAOH)
end

# Point in k-space
k=[0.0 0.0 0.0]'

bands=[]

for r in 0:0.02:1
    k=[r r 0]' # Gamma -> X?
    append!(bands,bandsfork(k))
end

display(bands)

print(bands)
