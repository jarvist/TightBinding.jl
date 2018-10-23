# Julia implementation of Polarisable Ion Tight Binding
#
# Starting with:
# Universal tight binding model for chemical reactions in solution and at surfaces. II. Water
# A. Y. Lozovoi1, T. J. Sheppard1, D. L. Pashov2, J. J. Kohanoff1, and A. T. Paxton2, a)
# The Journal of Chemical Physics 141, 044504 (2014);
# https://doi.org/10.1063/1.4890343
#
# TODO: Fix all the things.

#module PITB # PolarisableIonTightBinding ; OK, shorter form easier to play with

include("FunctionMacros.jl") # Macros to construct functions 
include("Lozovoi.jl") # parameters for 2014 Lozovoi paper; H20, corrected
#include("PolynomialApproximation.jl") # usin ApproxFun to speedup evaluation

#end
