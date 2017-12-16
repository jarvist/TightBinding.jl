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

# Vaguely structured to look like the Solid State Table of the Elements
# Using struct so type immutable; allows for efficient memory use and type stability
# Current just considering 'simple atoms' form - SP hybridising semiconductors
struct SolidStateTableEntry
    name::AbstractString
    Z::Int

    Es::Float64
    Ep::Float64

    kF::Float64
    rc::Float64
    ri::Float64
    
    mass::Float64
end

SSTE=SolidStateTableEntry # an alias to shorten the following lines; the full name appears in the REPL etc.

SolidStateTable=Array{SSTE}(92) # only up to 92=U currently!
SST=SolidStateTable

# OK; here is the actual data
#  "If it's not checked, it's wrong" - Slogan at Bletchley Park
# These values are not well checked.
SST[1]=SSTE("H" ,1,   NaN,NaN,      NaN,NaN,NaN,      1.0)
SST[2]=SSTE("He",2,   23.4,NaN,     NaN,NaN,NaN,      4.0)
SST[3]=SSTE("Li",3,   5.48,NaN,     1.13,0.92,0.68,   6.94)

SST[4]=SSTE("Be",4,   8.17,4.14,    1.94,0.58,0.30,   9.01)
SST[5]=SSTE("B", 5,   12.54,6.64,   NaN,0.44,0.16,    10.81)
SST[6]=SSTE("C", 6,   17.52,8.97,   2.76,0.37,NaN,    12.01)
SST[7]=SSTE("N", 7,   23.04,11.47,  NaN,NaN,NaN,      14.01)  
SST[8]=SSTE("O", 8,   29.14,14.13,  0,0.42,1.46,      16.00) 
# OK, not trying to be comprehensive at this point - let's just get some tetrahedral semiconductors on!

SST[14]=SSTE("Si",14, 13.55,6.52,   1.81,0.56,0.38,   28.09)
SST[15]=SSTE("P", 15, 17.10,8.33,   NaN,0.51,NaN,     30.97)
SST[16]=SSTE("S", 16, 20.80,10.27,  NaN,0.47,1.0,     32.06)

SST[29]=SSTE("Cu",29, 6.92,1.83,    1.36,NaN,NaN,     63.54)
SST[30]=SSTE("Zn",30, 8.40,3.38,    1.59,0.59,NaN,    65.37)
SST[31]=SSTE("Ga",31, 11.37,4.90,   1.66,0.59,NaN,    69.82)
SST[32]=SSTE("Ge",32, 14.38,6.36,   1.74,0.54,NaN,    72.59)
SST[33]=SSTE("As",33, 17.33,7.91,   NaN,0.51, NaN,    74.92)
SST[34]=SSTE("Se",34, 20.32,9.53,   NaN,0.50, NaN,    78.96)

SST[50]=SSTE("Sn",50, 12.50,5.94,   1.63,0.59,NaN,    118.7)

SST[53]=SSTE("I" ,53, 19.42,9.97,   NaN,NaN,2.16,     126.9)
SST[82]=SSTE("Pb",82, 12.07,5.77,   1.58,0.57,NaN,    207.2)

