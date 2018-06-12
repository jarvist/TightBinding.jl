# PolynomialApproximation.jl - polynomial approximations to FunctionalForm with ApproxFun package

using ApproxFun


# specify range of function. Too short + you end up with millions of polynomial coeffs
OHVssσFun=Fun(r->OHVssσ(r), 0.4..10)

# count number of coeffs
ncoefficients(OHVssσFun)

# plot the risidual
#plot( [x -> OHVssσFun(x) - OHVssσ(x)], 0.1,10 )

# derivative of the polynomial fit
OHVssσFunDeriv=OHVssσFun'

# Shouldn't really be doing computation in the src... Oh well!

println("Testing ApproxFun...")

orig=OOPP # OOPP is an EPL 

for rcut in 0.05:0.1:0.5
    origFun=Fun(r->orig(r), rcut..10)
    coeff=ncoefficients(origFun)
    resid=origFun(1.0)-orig(1.0)
    println("rcut: $rcut ncoeff OHVssσFun=Fun: $coeff Residual@1.0: $resid")
    print("ApproxFun: ")
    @time map(origFun,0.1:0.01:10)
    print("Original: ")
    @time map(orig,0.1:0.01:10)
end

