push!(LOAD_PATH,"../src/") # load module from local directory

using HarrisonSolidStateTable 
using Base.Test

include("SolidStateTable-test.jl")

include("ZincBlend-test.jl")

println("Tests finished succesfully.")

