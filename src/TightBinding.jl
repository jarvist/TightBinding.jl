
module TightBinding

using JuLIP, StaticArrays
using JuLIP: @protofun
using JuLIP.Potentials: @pot, SitePotential

import JuLIP: energy, forces, cutoff
import JuLIP.Potentials: evaluate, evaluate_d

# using FixedSizeArrays
export hamiltonian, densitymatrix




# ============================================================================


# abstractions
include("types.jl")

# define how to go from eigenvalues (energy-levels) to potential energy
include("smearing.jl")

# BZ integration: basic prototype; TODO: implement more efficient BZ grids!
include("bzintegration.jl")

# ============= SLATER KOSTER TYPE MODELS ================

# basics for slater-koster type hamiltonians
include("sk_core.jl")
include("slaterkoster.jl")
include("matrixassembly.jl")

# the TB toy model for quick tests (a slater-koster s-orbital model)
include("toymodel.jl")

# the NRLTB model
include("NRLTB.jl")

# The Kwon model - a simple orthogonal TB model for Silicon
# include("kwon.jl")

# ==================  for now, the calculators get to depend on SK again

# generic code, such as computing spectral decoposition,
# energy, forces (given the hamiltonian and hamiltonian derivatives)
include("calculators.jl")

# implement the contour integral variants of the TB model
# include("contour.jl")




# perturbation theory module
# include("perturbation.jl")

# implements the "classical" site energy
# include("site_energy.jl")

end    # module
