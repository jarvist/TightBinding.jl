[![Build Status](https://travis-ci.org/cortner/TightBinding.jl.svg?branch=master)](https://travis-ci.org/cortner/TightBinding.jl)
[![Coverage Status](https://coveralls.io/repos/cortner/TightBinding.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/cortner/TightBinding.jl?branch=master)
[![codecov.io](http://codecov.io/github/cortner/TightBinding.jl/coverage.svg?branch=master)](http://codecov.io/github/cortner/TightBinding.jl?branch=master)


# TightBinding.jl

This is an implementation of Slater-Koster type tight-binding models.
The intention is to have a flexible but fairly performant tight-binding
code to experiment with new models, and non-standard multi-scale schemes.

## Installation

`TightBinding.jl` is not registered, install by cloning:
```julia
Pkg.clone("https://github.com/cortner/TightBinding.jl.git")
```

The `master` branch requires `Julia v0.6`. To use `TightBinding.jl` with
`Julia v0.5` checkout the `v0.5` branch: from the Julia REPL this can be
achieved via
```julia
cd(Pkg.dir("TightBinding"))
run(`git checkout v0.5`)
```

Please run
```julia
Pkg.test("TightBinding")
```
and file an issue if there are any failed tests.

## Tight binding models

The codes are fairly flexible; a custom model of Slater-Koster form can be implemented fairly quickly. See [/src/model/sk_core.jl](/src/model/sk_core.jl) and [/src/model/matrixassembly.jl](/src/model/matrixassembly.jl) for convenience functions.

### Toy model

This implements a simple s-orbital tight-bidning Hamiltonian. The hopping integral is from any specified pair potential, but the default is a Morse potential.

### NRL tight binding

This implements the 'NRL' tight-binding Hamiltonian from the group of Papaconstantopoulos. Built into the Julia source code are parameters for `Si` with a {s,p} and {s,p,d} basis, and `C` with {s,p} and `Al` with {s,p,d}.

Parameters hosted on the NRL server can be downloaded from the Wayback machine archive, using the helper script `nrl_data/scrape_params.sh`. 

Please see the archived website for further details: https://web.archive.org/web/20121003160812/http://cst-www.nrl.navy.mil/bind/

### kwon

Hamiltonian for an orthogonal sp TB model of Si developed by Kwon et al.

I. Kwon, R. Biswas, C. Z. Wang, K. M. Ho and C. M. Soukoulis.
Transferable tight-binding models for silicon.
Phys Rev B 49 (11), 1994. 
https://doi.org/10.1103/PhysRevB.49.7242

This implementation deviates  from the above paper in how the cut-off is applied:
instead of "patching" a cubic spline between r1 and rcut, we simply multiply
with a quintic spline on the interval [0.5 (rcut + r0), rcut].

### Harrison / Solid State Table

An implementation of Walter A. Harrison's tight-binding method, with parameters as described in his Solid State Table. 

See Walter A. Harrison, Electronic structure and the properties of solids. https://www.amazon.co.uk/Electronic-Structures-Properties-Solids-Physics/dp/0486660214
This book enables, by the use of an empirical Linear Combination of Atomic Orbitals (LCAO) minimal basis and tight-binding Hamiltonian, to "calculate nearly any property of any solid, using a hand-held calculator".

### Polarisable ion tight binding

A work in progress to implement polarisable ion tight binding, and Gaussian multipole polarisable ion tight binding (https://doi.org/10.1063/1.4964391).

## Authors

This module was written by [Huajie Chen](https://github.com/hjchen1983) 
and [Christoph Ortner](http://homepages.warwick.ac.uk/staff/C.Ortner/). 
The FermiContour submodule was merged from
[FermiContour.jl](https://github.com/ettersi/FermiContour.jl) by
[ettersi](https://github.com/ettersi). 
The HarrisonSolidStateTable and Polarisable Ion Tight Binding was merged from 
[HarrisonSolidStateTable.jl](https://github.com/jarvist/HarrisonSolidStateTable.jl) by
[Jarvist Moore Frost](https://github.com/jarvist).


