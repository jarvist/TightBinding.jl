# Julia typed form of the Harrison solid state table
# Walter A. Harrison - Electronic structure & the property of solids

export ZfromAtom, SolidStateTableEntry, SSTE, SolidStateTable, SST 

# First we need to dereference atom name to atomic charge (Z)
ZfromAtom=Dict(j=>i for (i,j) in enumerate(["H","He",
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
SST[1]=SSTE("H" ,1, 0,0,    0,0,0,               1.0)
SST[2]=SSTE("He",2, 23.4,0, 0,0,0,               4.0)
SST[3]=SSTE("Li",3, 5.48,0, 1.13,0.92,0.68,      6.94)

SST[4]=SSTE("Be",4, 8.17,4.14,  1.94,0.58,0.30,  9.01)
SST[5]=SSTE("B", 5, 12.54,6.64, 0,0.44,0.16,    10.81)


