
module TightBinding

using JuLIP, StaticArrays
using JuLIP: @protofun
using JuLIP.Potentials: @pot, SitePotential

import JuLIP: energy, forces, cutoff
import JuLIP.Potentials: evaluate, evaluate_d, site_energy, site_energy_d,
                        partial_energy, partial_energy_d

export hamiltonian, densitymatrix, TBModel, TightBindingModel


# ============================================================================


# abstractions
include("types.jl")

# chemical potentials
# define how to go from spectrum (energy-levels) to potential energy
include("potentials.jl")

# BZ integration: MPGrid and GammaPoint, iterators, etc
include("bzintegration.jl")

# Construction of contours for PEXSI
include("FermiContour.jl")

include("PeriodicTable.jl") # basic convenience mapping function
# obsolete - should move over to cortner's JuLIP form.

# ============= SLATER KOSTER TYPE MODELS ================

# basics for slater-koster type hamiltonians
include("model/sk_core.jl")

# assembling hamiltonian and hamiltonian derivatives
include("model/matrixassembly.jl")

# the TB toy model for quick tests (a slater-koster s-orbital model)
include("model/toymodel.jl")

# the NRLTB model
include("model/NRLTB.jl")

# The Kwon model - a simple orthogonal TB model for Silicon
include("model/kwon.jl")

# Harrison solid-state-table
include("model/SolidStateTable.jl")

# Polarisable ion tight-binding
include("model/PolarisableIonTightBinding.jl")

# =================== END OF MODELS ======================

# generic code, such as computing spectral decoposition, energy, forces
include("calculators.jl")

# Convenience functions for calculating + plotting high symmetry paths in the
# Brillouin zone (i.e. 'band structures')
include("HighSymmetryPath.jl")

# pole expansion (contour integration) based calculator for TBModel
include("pexsi.jl")

# TODO: perturbation theory module
# include("perturbation.jl")

end    # module
