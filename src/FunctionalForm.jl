# FunctionalForm.jl - explicit form of pair-potentials

# Goodwin--Skinner--Pettifor
macro GSP(A,n, nc,r0,rc)
    return :(r -> $A*($r0/r)^$n * exp( $n*(-(r/$rc)^$nc + ($r0/$rc)^$nc)) ) 
end

# Exponential x power law
#   Written as a crazy summation expansion for the joy of it.
# FIXME: Currently only 'works' with one set of An mn pn values.
macro EPL(r0,An,mn,pn)
    sum=:()
    for (A,m,p) in zip(An,mn,pn)
        sum = :($sum + $A * ($r0/r)^$m * exp(-$p *(r-$r0)) )
    end
    println("sum: ",sum)
    return :(r -> $sum) 
end

# TODO: EPL, QUAD

