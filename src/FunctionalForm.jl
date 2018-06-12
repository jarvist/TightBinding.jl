# FunctionalForm.jl - explicit form of pair-potentials

# Goodwin--Skinner--Pettifor
macro GSP(A,n, nc,r0,rc)
    return :(r -> $A*($r0/r)^$n * exp( $n*(-(r/$rc)^$nc + ($r0/$rc)^$nc)) ) 
end

# Exponential x power law
#   Written as a crazy summation expansion for the joy of it.
macro EPL(r0,An,mn,pn)
    sum=:(0.0)
    for (A,m,p) in zip(An.args,mn.args,pn.args)
        sum=:($sum + $A * ($r0/r)^$m * exp(-$p *(r-$r0)) )
    end
    println("sum: ",sum)
    return :(r -> $sum) 
end

# Chadi's quadratic
macro QUAD(r0,A1,A2)
    return :(r -> $A1*(r-$r0) + $A2*(r-$r0)*(r-$r0) )
end

