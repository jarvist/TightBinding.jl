using TightBinding
using JuLIP
using JuLIP.Testing
using Base.Test

COMPAREATOMS = false    # if Atoms.jl is installed
COMPAREQUIP = false     # if QUIP and quippy are installed
TESTDEPTH = 0 # integer; higher number for more tests. Only used by nrltb.jl currently.

println("============================================")
println("    TightBinding Tests  ")
println("============================================")

@testset "TightBinding.jl" begin

# =========== Harrison solid-state table =======
@testset "Harrison solid-state table" begin
@testset "SolidStateTable-test.jl" begin
include("SolidStateTable-test.jl") end
@testset "ZincBlend-test.jl" begin
include("ZincBlend-test.jl") end
@testset "ShiPapaconstantopoulos-test.jl" begin
include("ShiPapaconstantopoulos-test.jl") end
@testset "PolynomialApproximation.jl" begin
include("PolynomialApproximation.jl") end
end
println("Harrison Tests finished succesfully.")

# =========== Main tests =================
@testset "testtoymodel.jl" begin
include("testtoymodel.jl") end
@testset "testnrltb.jl" begin
include("testnrltb.jl") end
@testset "testcontour.jl" begin
include("testcontour.jl") end
@testset "testsiteE.jl" begin
include("testsiteE.jl") end
@testset "testkwon.jl" begin
include("testkwon.jl") end
@testset "testdual.jl" begin
include("testdual.jl") end
# @testset "test0T.jl" begin
# include("test0T.jl") end

# ============= Compare with Atoms.jl and QUIP implementations
if COMPAREATOMS; include("compareatoms.jl"); end
if COMPAREQUIP; include("comparequip.jl"); end

# ============= Performance benchmarks
# (uncomment these only for performance tests)
# include("benchmarkEandFrc.jl")
# include("perfsiteE.jl")
end

