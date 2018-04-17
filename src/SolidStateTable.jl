# Julia typed form of the Harrison solid state table
# Walter A. Harrison - Electronic structure & the property of solids

export SolidStateTableEntry, SSTE, SolidStateTable, SST 
export HarrisonIME, HarrisonShiAltIME, ShiIME

# Interatomic matrix elements (eta, η)
# Harrison, 'Solid State Table' parameters, top right table
# TODO: Check; and wrap these in a struct
struct InterAtomic
    ηssσ::Float64
    ηspσ::Float64
    ηppσ::Float64
    ηppπ::Float64

    ηsdσ::Float64
    ηpdσ::Float64
    ηpdπ::Float64

    ηddσ::Float64
    ηddπ::Float64
    ηddδ::Float64
end

# Nb: These are from the Dover reprint of Harrison's book (El-strucut & the prop of solids)
HarrisonIME=InterAtomic(-1.40,+1.84,+3.24,-0.81, -3.16,-2.95,+1.36, -16.2,+8.75,+0.0)

# Shi and Papaconstantopoulos give quite different values for Harrison;
# s and p are totally different; d mostly the same except for ddδ (last value)
#   Table I https://doi.org/ 10.1103/PhysRevB.70.205101
HarrisonShiAltIME=InterAtomic(-1.32,+1.42,+2.22,-0.63, -3.16,-2.95,+1.36, -16.2,+8.75,-2.39)

# Shi and Papconstantopoulos - improved values for d-block 
#   See Table I https://doi.org/ 10.1103/PhysRevB.70.205101
ShiIME=     InterAtomic(-0.90,+1.44,+2.19,-0.03, -3.12,-4.26,+2.08, -21.22,+12.60,-2.29)

# Vaguely structured to look like the Solid State Table of the Elements
# Using struct so type immutable; allows for efficient memory use and type stability
# Current just considering 'simple atoms' form - SP hybridising semiconductors
struct SolidStateTableEntry
    name::AbstractString
    Z::Int

    ϵs::Float64
    ϵp::Float64
    ϵd::Float64

    kF::Float64
    rc::Float64 # also re-used for r0 (or ro?) of d-block 
    ri::Float64

    γ::Float64
    
    mass::Float64
end

SSTE=SolidStateTableEntry # an alias to shorten the following lines; the full name appears in the REPL etc.

SolidStateTable=Array{SSTE}(92) # only up to Z=92 , uranium currently!
SST=SolidStateTable

# Constructor methods
# SIMPLE ATOMS
SSTp(name,Z,ϵs,ϵp,kF,rc,ri,mass)=SSTE(name,Z,ϵs,ϵp,NaN, kF,rc,ri, NaN, mass)
# TRANSITION METALS (we call this d for 'd block')
SSTd(name,Z,ϵd,rd,kd,ro,ri,mass)=SSTE(name,Z,NaN,NaN,ϵd, NaN, ro, ri, NaN, mass) 
# F-SHELL METALS
SSTf()=SSTE() # TODO: Implement f-shell in data structure

# Shi-Papaconstantopoulos
# 2004 https://doi.org/10.1103/PhysRevB.70.205101 ; 21st century improved d-orbital values
SSTShi(name,Z,ϵs,ϵp,ϵd,γ,rd)=SSTE(name,Z, ϵs,ϵp,ϵd, NaN, rd, γ, mass)

# OK; here is the actual data - as in Harrison's book

#  "If it's not checked, it's wrong" - Slogan at Bletchley Park
# These values are not well checked.
SST[1]=SSTp("H" ,1,   NaN,NaN,      NaN,NaN,NaN,      1.0)
SST[2]=SSTp("He",2,   23.4,NaN,     NaN,NaN,NaN,      4.0)
SST[3]=SSTp("Li",3,   5.48,NaN,     1.13,0.92,0.68,   6.94)

SST[4]=SSTp("Be",4,   8.17,4.14,    1.94,0.58,0.30,   9.01)
SST[5]=SSTp("B", 5,   12.54,6.64,   NaN,0.44,0.16,    10.81)
SST[6]=SSTp("C", 6,   17.52,8.97,   2.76,0.37,NaN,    12.01)
SST[7]=SSTp("N", 7,   23.04,11.47,  NaN,NaN,NaN,      14.01)  
SST[8]=SSTp("O", 8,   29.14,14.13,  0,0.42,1.46,      16.00) 
# OK, not trying to be comprehensive at this point - let's just get some tetrahedral semiconductors on!

SST[12]=SSTp("Mg",12, 6.86, 2.99,   1.37,0.74,0.65,   24.31)

SST[14]=SSTp("Si",14, 13.55,6.52,   1.81,0.56,0.38,   28.09)
SST[15]=SSTp("P", 15, 17.10,8.33,   NaN,0.51,NaN,     30.97)
SST[16]=SSTp("S", 16, 20.80,10.27,  NaN,0.47,1.0,     32.06)

SST[22]=SSTd("Ti",22, 11.04, 1.08, 1.17, 1.61,0.90,   47.90) # EEK- FIXME : D-block not correct form.

# Cu is special - also has d-block params?
SST[29]=SSTp("Cu",29, 6.92,1.83,    1.36,NaN,NaN,     63.54) # 'simple' atom form
SST[30]=SSTp("Zn",30, 8.40,3.38,    1.59,0.59,NaN,    65.37) # FIXME: also D-block; incorrect form
SST[31]=SSTp("Ga",31, 11.37,4.90,   1.66,0.59,NaN,    69.82)
SST[32]=SSTp("Ge",32, 14.38,6.36,   1.74,0.54,NaN,    72.59)
SST[33]=SSTp("As",33, 17.33,7.91,   NaN,0.51, NaN,    74.92)
SST[34]=SSTp("Se",34, 20.32,9.53,   NaN,0.50, NaN,    78.96)

SST[50]=SSTp("Sn",50, 12.50,5.94,   1.63,0.59,NaN,    118.7)

SST[53]=SSTp("I" ,53, 19.42,9.97,   NaN,NaN,2.16,     126.9)
SST[82]=SSTp("Pb",82, 12.07,5.77,   1.58,0.57,NaN,    207.2)

