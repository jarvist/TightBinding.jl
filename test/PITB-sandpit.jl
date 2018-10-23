push!(LOAD_PATH,"../src/") # load module from local directory

include("../src/PolarisableIonTightBinding.jl")
using Plots

# Plot pair potential; O-H bond integrals
plot([PITB.OOPP, PITB.OHVssσ, PITB.OHVpsσ],1.0,4.0)

