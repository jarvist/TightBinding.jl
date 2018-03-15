# FunctionalForm.jl - explicit form of pair-potentials

macro GSP(A,n, nc,r0,rc)
    return :(r -> $A*($r0/r)^$n * exp( $n*(-(r/$rc)^$nc + ($r0/$rc)^$nc)) ) 
end

# TODO: EPL, QUAD

