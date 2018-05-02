
using JuLIP: set_transient!, get_data, has_data


# this file implements the standard spectral decomposition
# calculator for energy, forces, etc.

# ================= diagonalisation ====================
#
# we discussed whether to distinguish k = 0 (Real, Symmetric),
# k ≠ 0 (Complex, Hermitian). For large systems with only Gamma-point,
# this might seem useful, but it actually seems that the timings are
# not so different, e.g., for a 1000 x 1000 system,
#    Float64 ~ 400ms, Complex128 ~ 500ms per `eig`.
# this indicates that we probably shouldn't bother.
# This is difference, btw, for LU decompositions, so for the Contour
# calculator we will most likely


"""
`sorted_eig`:  helper function to compute eigenvalues, then sort them
in ascending order and sort the eig-vectors as well.
"""
function sorted_eig(H::Matrix, M::Matrix)
   epsn, C = eig(Hermitian(H), Hermitian(M))
   Isort = sortperm(epsn)
   return epsn[Isort], C[:, Isort]
end

function sorted_eig(H::Matrix, ::UniformScaling)
   epsn, C = eig(Hermitian(H))
   Isort = sortperm(epsn)
   return epsn[Isort], C[:, Isort]
end


"""
`update_eig!(atm::AbstractAtoms, tbm::TBModel)` : updates the hamiltonians
and spectral decompositions on the MP grid.
"""
function update_eig!{ISORTH}(atm::AbstractAtoms, H::SparseSKH{ISORTH}, tbm::TBModel)
   wrk = _alloc_full(H)
   for (w, k) in tbm.bzquad
      if !has_k_array(atm, :epsn, k)
         Hf, Mf = full!(wrk, H, k)
         epsn, C = sorted_eig(Hf, Mf)
         # TODO: probably remove this - but need to rewrite site_energy first
         set_k_array!(atm, Mf, :M, k)
         set_k_array!(atm, epsn, :epsn, k)
         set_k_array!(atm, C, :C, k)
      end
   end
end


# ==================== update all arrays =================
#    e.g., prior to an energy or force calculation


"""
`update!(atm::AbstractAtoms, tbm:TBModel)`: checks whether the precomputed
data stored in `at` is still there - JuLIP deletes all arrays when
atom positions are updated.

* spectral decompositions (`update_eig!`)
* the fermi-level (`update_eF!`)
"""
function update!(at::AbstractAtoms, tbm::TBModel)
   # check whether the :tbupdateflag exists;  if it does then atom positions
   # have not changed since last time that update! was called
   if has_data(at, :tbupdateflag)
      return nothing
   end
   # set the update flag (will be deleted as soon as atom positions change)
   # ( we do this *before* the update so that we don't go into an infinite
   #    loop with the update trying to update; see e.g. BZiter )
   set_transient!(at, :tbupdateflag, 0)
   # if the flag does not exist, then we update everything
   skh = SparseSKH(tbm.H, at)  # this also stores skh for later use
   update_eig!(at, skh, tbm)
   update!(at, tbm.potential, tbm)
   return nothing
end



# ================ Density Matrix and Energy ================


"""
`densitymatrix(tbm, at) -> Γ`:

### Input

* `tbm::TBModel` : calculator
* `at::AbstractAtoms` : configuration

### Output

`Γ::Matrix{Float64}`: density matrix Γ = Σ_k w^k Σ_s f(ϵ_s^k) ψ_s^k ⊗ ψ_s^k
and f(ϵ) is the occupancy
"""
function densitymatrix(tbm::TBModel, at::AbstractAtoms)
   N = ndofs(tbm.H, at)
   Γ = zeros(N, N)
   for (w, _, ϵ, ψ) in BZiter(tbm, at)
      fs = occupancy(tbm.potential, ϵ)
      for a = 1:N, b = 1:N
         Γ[a,b] += w * fs * real(ψ[a] * ψ[b]')
      end
   end
   return Γ
end


# this is imported from JuLIP
energy(tbm::TBModel, at::AbstractAtoms) = (
   sum( w * energy(tbm.potential, ϵ) for (w, _1, ϵ, _2) in BZiter(tbm, at) )
   + energy(tbm.Vrep, at) )

# function energy(tbm::TBModel, at::AbstractAtoms)
#    update!(at, tbm)
#    Etot = 0.0
#    for (w, k) in tbm.bzquad
#       epsn_k = get_k_array(at, :epsn, k)
#       Etot += w * sum( energy(tbm.potential, epsn_k) )
#    end
#    return Etot # + energy(tbm.Vrep, at)
# end

# ========================== Forces ==========================

# this is an old force computation that requires a SKHamiltonian structure
#    F_n = - ∑_s f'(ϵ_s) < ψ_s | H,n - ϵ_s * M,n | ψ_s >
# but instead of computing H,n, M,n as matrices, this assembly loops over
# the non-zero blocks first and the inner loop is over the derivative ,n
# it prevents allocating lots of sparse matrices for the hamiltonian
# derivatives.

function _forces_k!{ISORTH, NORB}(frc::Vector{JVecF},
                                 at::AbstractAtoms, tbm::TBModel,
                                 H::SKHamiltonian{ISORTH,NORB}, k::JVecF,
                                 skhg, w)
   # obtain the precomputed arrays
   epsn = get_k_array(at, :epsn, k)::Vector{Float64}
   C = get_k_array(at, :C, k)::Matrix{Complex128}
   df = grad(tbm.potential, epsn)::Vector{Float64}

   # precompute some products
   # TODO: optimise these two lines? These are O(N^3) scaling, while overall
   #       force assembly should be just O(N^2) (but can we beat BLAS3?)
   C_df_Ct = (C * (df' .* C)')
   C_dfepsn_Ct = (C * ((df.*epsn)' .* C)')

   # an array replacing dM_ij when the model is orthogonal
   dM_ij = zero(typeof(skhg.dH[1]))

   for n = 1:length(skhg.i)
      i, j, dH_ij, dH_ii, S = skhg.i[n], skhg.j[n], skhg.dH[n], skhg.dOS[n], skhg.Rcell[n]
      if !ISORTH; dM_ij = skhg.dM[n]; end
      Ii, Ij = indexblock(i, H), indexblock(j, H)
      eikr = exp(im * dot(S, k))::Complex{Float64}

      @inbounds for a = 1:NORB, b = 1:NORB
         t1 = 2.0 * real(C_df_Ct[Ii[a], Ij[b]] * eikr)
         t2 = 2.0 * real(C_dfepsn_Ct[Ii[a], Ij[b]] * eikr)
         t3 = real(C_df_Ct[Ii[a],Ii[b]])
         frc[j] += (-t1) * dH_ij[:,a,b] + t2 * dM_ij[:,a,b] - t3 * dH_ii[:,a,b]
         frc[i] += t3 * dH_ii[:,a,b]
      end
   end

   return frc
end


# * `forces` is imported from JuLIP
# * this implementation is the old version from Atoms.jl, which makes
#   specific assumptions about the structure of the hamiltonian, hence is
#   only valid for SK-type hamiltonians.
#
function forces{HT <: SKHamiltonian}(tbm::TBModel{HT}, atm::AbstractAtoms)
   update!(atm, tbm)
   skhg = SparseSKHgrad(tbm.H, atm)
   frc = forces(tbm.Vrep, atm)
   # frc = zerovecs(length(atm))
   for (w, k) in tbm.bzquad
      _forces_k!(frc, atm, tbm, tbm.H, k, skhg, w)
   end
   return frc
end


function partial_energy(tbm::TBModel, at::AbstractAtoms,
                        Idom::AbstractVector{TI})    where TI <: Integer
   update!(at, tbm)
   In0 = indexblock(Idom, tbm.H)
   E = 0.0
   for (w, k) in tbm.bzquad
      epsn_k = get_k_array(at, :epsn, k)
      M_k = get_k_array(at, :M, k)
      C_k = get_k_array(at, :C, k)
      MC_k = isorth(tbm) ? C_k[In0,:] : (M_k[In0, :] * C_k)
      ψ² = sum( conj(C_k[In0, :] .* MC_k), 1 )[:]
      E += w * sum(energy(tbm.potential, epsn_k)  .* ψ²)
   end
   return real(E) + partial_energy(tbm.Vrep, at, Idom)
end


site_energy(tbm::TBModel, at::AbstractAtoms, n0::Integer) =
      partial_energy(tbm, at, [n0])


# ================ Band-structure =================

"""
`band_structure(tbm::TBModel, at::AbstractAtoms) -> k, E`

where
* `k` is a list of k-points
* `E` is a ndofs x nk matrix of energies
"""
function band_structure(tbm::TBModel, at::AbstractAtoms)
   update!(at, tbm)
   na = ndofs(tbm.H, at)
   K = JVecF[]
   E = Float64[]
   for (w, k) in tbm.bzquad
      push!(K, k)
      append!(E, get_k_array(at, :epsn, k))
   end
   return K, reshape(E, na, length(E) ÷ na)
end

"""
`spectrum(tbm, at) -> E::Vector`
"""
spectrum(tbm, at) = band_structure(tbm, at)[2][:]

function spectrum(k::JVec, tbm::TBModel, at::AbstractAtoms)
   wrk = _alloc_full(H)
   H = SparseSKH(tbm.H, at)
   Hk, Mk = full!(wrk, H, k)
   epsn, C = sorted_eig(Hk, Mk)
   return epsn
end

band_structure(K::AbstractVector{JVec}, tbm::TBModel, at::AbstractAtoms) =
   [ spectrum(k, tbm, at) for k in K ]


# """
# `band_structure_near_eF(Nb::Integer, at::AbstractAtoms, tbm::TBModel) -> k, E`
#
# get 2*Nb+1 bands around the fermi level
# """
# function band_structure_near_eF(Nb, at::AbstractAtoms, tbm::TBModel)
#    update!(at, tbm)
#    Ne = ndofs(tbm.H, at)
#    K = JVecF[]
#    E = Float64[]
#    eF = get_eF(tbm.potential)
#    for (w, k) in tbm.bzquad
#       push!(K, k)
#       epsn_k = get_k_array(tbm, :epsn, k)
#
#       E[Nb+1,n] = epsn_k[nf]
#       for j = 1:Nb
#          E[Nb+1-j,n] = epsn_k[nf-j]
#          E[Nb+1+j,n] = epsn_k[nf+j]
#       end
#    end
#    return K, E
# end



# =================== Site Forces for a given k-point =======================
# The derivatives of the site energy is computed by dual technique.
# E_{ℓ,k} = ∑_s f'(ɛ_s)⋅ɛ_{s,n}⋅[ψ_s]_{ℓ}⋅[M*ψ_s]_{ℓ}         (=:T1)
#           + ∑_s f(ɛ_s)⋅[ψ_s]_ℓ⋅[M_{,k}⋅ψ_s]_ℓ               (=:T2)
#           + ∑_s f(ε_s)⋅[ψ_s]_{ℓ}⋅[M ψ_{s,k}]_ℓ              (=:T3)
#           + ∑_s f(ε_s)⋅[ψ_s]_{ℓ,k}⋅[M ψ_s]_ℓ                (=:T4)
#           - ∑_s f(ε_s)⋅⟨ψ_s|M_{,k}|ψ_s⟩⋅⟨ψ_s|M_{,k}|ψ_s⟩_ℓ  (=:T5)
# Note that T5 comes from the pseudo iverse part that can not be handeled
# by dual technique.
# When ISORTH == true, we have T5 = 0 !
# Dual technique for T3:
# T3 = ∑_s f(ϵ_s)⋅⟨(H-ϵ_s⋅M)⁻[ψ_s]_{ℓ},(-H_{,k}+ϵ_s⋅M_{,k}+ϵ_{s,k}⋅M)ψ_s⟩

function _dEs_k!(dEs::Vector{JVecF},
                  at::AbstractAtoms, tbm::TBModel,
                  H::SKHamiltonian{ISORTH,NORB}, k::JVecF,
                  skhg, w, Idom::AbstractVector{TI}
         ) where {ISORTH, NORB, TI <: Integer}

   # obtain the orbital-indices corresponding to the site indices `Idom`
   In0  = indexblock(Idom, tbm.H)
   # obtain the precomputed arrays
   epsn = get_k_array(at, :epsn, k)::Vector{Float64}
   C    = get_k_array(at, :C, k)::Matrix{Complex128}
   f    = energy(tbm.potential, epsn)::Vector{Float64}
   df   = grad(tbm.potential, epsn)::Vector{Float64}
   M    = get_k_array(at, :M, k)
   MC   = isorth(tbm) ? C[In0,:] : (M[In0, :] * C)
   ψ²   = sum( conj(C[In0, :]) .* MC , 1 )[:]
   # precompute some products
   C_f_Ct         = (C * (f' .* C)')
   C_f_ψ²_Ct      = (C * ( (f .* ψ²)' .* C )')
   C_df_ψ²_Ct     = (C * ( (df .* ψ²)' .* C )')
   C_dfepsn_ψ²_Ct = (C * ( (df .* epsn .* ψ²)' .* C )')
   # an array replacing dM_ij when the model is orthogonal
   dM_ij = zero(typeof(skhg.dH[1]))

   # precompute pseudo-inverse:
   # (H-ϵ_s⋅M)⁻[ψ_s]_{ℓ} = ∑_t (ϵ_t-ϵ_s)^{-1}⋅ ( [ψ_s]_ℓ⋅[M ψ_t]_ℓ + [M ψ_s]_ℓ⋅[ψ_t]_ℓ )⋅ψ_k
   Nelc = length(epsn)
   diff_eps_inv_ψst = zeros(Float64, Nelc, Nelc)
	for t = 1:Nelc, s = 1:Nelc
		if abs(epsn[t]-epsn[s]) > 1e-10
        	diff_eps_inv_ψst[t,s] =  # 2.0 * ( C[In0,t]' * C[In0,s] )[1]
                     ( C[In0,s]' * MC[:,t] + C[In0,t]' * MC[:,s] )[1] / (epsn[s]-epsn[t])
      else
        	diff_eps_inv_ψst[t,s] = 0.0
      end
	end
   pinvC = C * diff_eps_inv_ψst
   # precompute some products analogous to C_df_Ct
   pinvC_f_Ct = (pinvC * (f' .* C)')
   pinvC_fepsn_Ct = (pinvC * ( (f .* epsn)' .* C )')

   for n = 1:length(skhg.i)
      i, j, dH_ij, dH_ii, S = skhg.i[n], skhg.j[n], skhg.dH[n], skhg.dOS[n], skhg.Rcell[n]
      if !ISORTH; dM_ij = skhg.dM[n]; end
      Ii, Ij = indexblock(i, H), indexblock(j, H)
      eikr = exp(im * dot(S, k))::Complex{Float64}
      @inbounds for a = 1:NORB, b = 1:NORB
         # add T1 part
         t1 = 2.0 * real(C_df_ψ²_Ct[Ii[a],Ij[b]] * eikr)
         t2 = 2.0 * real(C_dfepsn_ψ²_Ct[Ii[a],Ij[b]] * eikr)
         t3 = real(C_df_ψ²_Ct[Ii[a],Ii[b]])
         dEs[j] += t1 * dH_ij[:,a,b] - t2 * dM_ij[:,a,b] + t3 * dH_ii[:,a,b]
         dEs[i] += - t3 * dH_ii[:,a,b]
         # add T2 part
         if i ∈ Idom  # should be i ∈ n0, when n0 is a int vector...
            # t4 = 2.0 * real(C_f_Ct[Ii[a], Ij[b]] * eikr)
            t4  = real(C_f_Ct[Ii[a], Ij[b]] * eikr) #+ real(C_f_Ct[Ij[b], Ii[a]] * eikr)
            dEs[j] += t4 * dM_ij[:,a,b]
            dEs[i] += - t4 * dM_ij[:,a,b]
         end
         # add T3 & T4 part
         # t5 = 2.0 * real(pinvC_f_Ct[Ii[a],Ij[b]] * eikr)
         # t6 = 2.0 * real(pinvC_fepsn_Ct[Ii[a],Ij[b]] * eikr)
         # Be careful: the matrix pinvC_f_Ct is not symmetric !!
         t5 = real(pinvC_f_Ct[Ii[a],Ij[b]] * eikr) +
              real(pinvC_f_Ct[Ij[b],Ii[a]] * eikr)
         t6 = real(pinvC_fepsn_Ct[Ii[a],Ij[b]] * eikr) +
              real(pinvC_fepsn_Ct[Ij[b],Ii[a]] * eikr)
         t7 = real(pinvC_f_Ct[Ii[a],Ii[b]])
         dEs[j] += t5 * dH_ij[:,a,b] - t6 * dM_ij[:,a,b] + t7 * dH_ii[:,a,b]
         dEs[i] += - t7 * dH_ii[:,a,b]
         # add T5 part
         t8 = 2.0 * real(C_f_ψ²_Ct[Ii[a],Ij[b]] * eikr)
         dEs[j] += - t8 * dM_ij[:,a,b]
      end
   end

   # TODO: diagonalize for pertubation of degenerated eigenvalues
   #   But we need store different C_f_Ct for different partial derivatives?
   # The next two could be easy ...
   # TODO: extend to the case when n0 has more than one site
   # TODO: missing w in the calculations? (and so is the function forces)

   return dEs
end


# Derivative of site energy using dual technique
#
function partial_energy_d{HT <: SKHamiltonian, TI <: Integer}(
                        tbm::TBModel{HT}, atm::AbstractAtoms,
                        Idom::AbstractVector{TI})
   update!(atm, tbm)
   skhg = SparseSKHgrad(tbm.H, atm)
   dE = zerovecs(length(atm))
   for (w, k) in tbm.bzquad
      _dEs_k!(dE, atm, tbm, tbm.H, k, skhg, w, Idom)
   end
   return dE + partial_energy_d(tbm.Vrep, atm, Idom)
end


site_energy_d{HT <: SKHamiltonian}(tbm::TBModel{HT}, atm::AbstractAtoms,
                                    n0::Integer) =
   partial_energy_d(tbm, atm, [n0])
