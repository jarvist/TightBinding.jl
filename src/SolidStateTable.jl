# Julia typed form of the Harrison solid state table
# Walter A. Harrison - Electronic structure & the property of solids

export AtoZ, SolidStateTableEntry, SSTE, SolidStateTable, SST 

# First we need to dereference atom name to atomic charge (Z)
AtoZ=Dict(j=>i for (i,j) in enumerate(["H","He",
    "Li","Be","B","C","N","O","F","Ne",
    "Na","Mg","Al","Si","P","S","Cl","Ar",
    "K","Ca","Sc","Ti","V","Cr","Mn","Fe","Co","Ni","Cu","Zn","Ga","Ge","As","Se","Br","Kr",
    "Rb","Sr","Y","Zr","Nb","Mo","Tc","Ru","Rh","Pd","Ag","Cd","In","Sn","Sb","Te","I","Xe",
    "Cs","Ba","La",
    "Ce","Pr","Nd","Pm","Sm","Eu","Gd","Tb","Dy","Ho","Er","Tm","Yb","Lu",
    "Hf","Ta","W","Re","Os","Ir","Pt","Au","Hg","Tl","Pb","Bi","Po","At","Rn",
    "Fr","Ra","Ac","Th","Pa","U","Np","Pu","Am","Cm","Bk","Cf","Es","Fm","Md","No","Lr",
    "Rf","Db","Sg","Bh","Hs","Mt","Ds","Rg","Cn","Nh","Fl","Mc","Lv","Ts","Og"]))
# Magic comprehension ends up like:
# ZfromAtom = Dict("H" => 1, "He" => 2, "Li" => 3)

export ηssσ, ηspσ, ηppσ, ηppπ
# Interatomic matrix elements (eta, η)
const ηssσ = -1.40
const ηspσ = +1.84
const ηppσ = -1.40
const ηppπ = -0.81


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
    rc::Float64
    ri::Float64
    
    mass::Float64
end

SSTE=SolidStateTableEntry # an alias to shorten the following lines; the full name appears in the REPL etc.

SolidStateTable=Array{SSTE}(92) # only up to Z=92 , uranium currently!
SST=SolidStateTable

# Constructor methods
# SIMPLE ATOMS
SSTp(name,Z,ϵs,ϵp,kF,rc,ri,mass)=SSTE(name,Z,ϵs,ϵp,NaN, kF,rc,ri,mass)
# TRANSITION METALS (we call this d for 'd block')
SSTd(name,Z,ϵd,rd,kd,ro,ri,mass)=SSTE(name,Z,NaN,NaN,ϵd, NaN, NaN, ri,mass) # FIXME: currently fills in blanks for ro,kd
# F-SHELL METALS
SSTf()=SSTE() # TODO: Finish this
# OK; here is the actual data - as in Harrison's book

# See also 2004 https://doi.org/10.1103/PhysRevB.70.205101 for 21st century improved d-orbital values

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

