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

(TODO: Add DOIs to main references for these models; document other models in
/model).

### NRL tight binding



### Harrison / Solid State Table

An implementation of Walter A. Harrison's tight-binding method, with parameters as described in his Solid State Table. 

See Walter A. Harrison, Electronic structure and the properties of solids. https://www.amazon.co.uk/Electronic-Structures-Properties-Solids-Physics/dp/0486660214
This book enables, by the use of an empirical Linear Combination of Atomic Orbitals (LCAO) minimal basis and tight-binding Hamiltonian, to "calculate nearly any property of any solid, using a hand-held calculator".

### Polarisable ion tight binding



## Authors

This module was written by [Huajie Chen](https://github.com/hjchen1983) 
and [Christoph Ortner](http://homepages.warwick.ac.uk/staff/C.Ortner/). 
The FermiContour submodule was merged from
[FermiContour.jl](https://github.com/ettersi/FermiContour.jl) by
[ettersi](https://github.com/ettersi). 
The HarrisonSolidStateTable and Polarisable Ion Tight Binding was merged from 
[HarrisonSolidStateTable.jl](https://github.com/jarvist/HarrisonSolidStateTable.jl) by
[Jarvist Moore Frost](https://github.com/jarvist).


