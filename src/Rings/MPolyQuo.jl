##############################################################################
#
# quotient rings
#
##############################################################################

#TODO: add to singular_ring natively as this is potentially one
mutable struct MPolyQuo{S} <: AbstractAlgebra.Ring
  R::MPolyRing
  I::MPolyIdeal{S}
  AbstractAlgebra.@declare_other

  function MPolyQuo(R, I) where S
    @assert base_ring(I) == R
    r = new{elem_type(R)}()
    r.R = R
    r.I = I
    return r
  end
end

function show(io::IO, Q::MPolyQuo)
  Hecke.@show_name(io, Q)
  Hecke.@show_special(io, Q)
  io = IOContext(io, :compact => true)
  print(io, "Quotient of $(Q.R) by $(Q.I)")
end

gens(Q::MPolyQuo) = [Q(x) for x = gens(Q.R)]
ngens(Q::MPolyQuo) = ngens(Q.R)
gen(Q::MPolyQuo, i::Int) = Q(gen(Q.R, i))
Base.getindex(Q::MPolyQuo, i::Int) = Q(Q.R[i])

#TODO: think: do we want/ need to keep f on the Singular side to avoid conversions?
#      or use Bill's divrem to speed things up?
mutable struct MPolyQuoElem{S} <: RingElem
  f::S
  P::MPolyQuo{S}
end

AbstractAlgebra.expressify(a::MPolyQuoElem; context = nothing) = expressify(a.f, context = context)

function show(io::IO, a::MPolyQuoElem)
  print(io, AbstractAlgebra.obj_to_string(a, context = io))
end

function singular_ring(Rx::MPolyQuo; keep_ordering::Bool = true)
  Sx = singular_ring(Rx.R, keep_ordering = keep_ordering)
  groebner_assure(Rx.I)
  Q = Sx(Singular.libSingular.rQuotientRing(Rx.I.gb.S.ptr, Sx.ptr))
  return Q
end

parent_type(::MPolyQuoElem{S}) where S = MPolyQuo{S}
parent_type(::Type{MPolyQuoElem{S}}) where S = MPolyQuo{S}
elem_type(::MPolyQuo{S})  where S= MPolyQuoElem{S}
elem_type(::Type{MPolyQuo{S}})  where S= MPolyQuoElem{S}

canonical_unit(a::MPolyQuoElem) = one(parent(a))

parent(a::MPolyQuoElem) = a.P

function check_parent(a::MPolyQuoElem, b::MPolyQuoElem)
  a.P == b.P || error("wrong parents")
  return true
end

+(a::MPolyQuoElem, b::MPolyQuoElem) = check_parent(a, b) && MPolyQuoElem(a.f+b.f, a.P)
-(a::MPolyQuoElem, b::MPolyQuoElem) = check_parent(a, b) && MPolyQuoElem(a.f-b.f, a.P)
-(a::MPolyQuoElem) = MPolyQuoElem(-a.f, a.P)
*(a::MPolyQuoElem, b::MPolyQuoElem) = check_parent(a, b) && MPolyQuoElem(a.f*b.f, a.P)
^(a::MPolyQuoElem, b::Integer) = MPolyQuoElem(Base.power_by_squaring(a.f, b), a.P)

function Oscar.mul!(a::MPolyQuoElem, b::MPolyQuoElem, c::MPolyQuoElem)
  a.f = b.f*c.f
  return a
end

function Oscar.addeq!(a::MPolyQuoElem, b::MPolyQuoElem)
  a.f += b.f
  return a
end

function simplify!(a::MPolyQuoElem)
  R = parent(a)
  I = R.I
  groebner_assure(I)
  singular_assure(I.gb)
  Sx = base_ring(I.gb.S)
  f = a.f
  a.f = I.gens.Ox(reduce(Sx(f), I.gb.S))
  return a
end

function simplify(a::MPolyQuoElem)
  R = parent(a)
  I = R.I
  groebner_assure(I)
  singular_assure(I.gb)
  Sx = base_ring(I.gb.S)
  f = a.f
  return R(I.gens.Ox(reduce(Sx(f), I.gb.S)))
end


function ==(a::MPolyQuoElem, b::MPolyQuoElem)
  check_parent(a, b)
  simplify!(a)
  simplify!(b)
  return a.f == b.f
end

function quo(R::MPolyRing, I::MPolyIdeal) 
  q = MPolyQuo(R, I)
  function im(a::MPolyElem)
    return MPolyQuoElem(a, q)
  end
  function pr(a::MPolyQuoElem)
    return a.f
  end
  return q, MapFromFunc(im, pr, R, q)
end

function quo(R::MPolyRing, f::MPolyElem...) 
  return quo(R, ideal(R, [f...]))
end

lift(a::MPolyQuoElem) = a.f

(Q::MPolyQuo)() = MPolyQuoElem(Q.R(), Q)
(Q::MPolyQuo)(a::MPolyQuoElem) = a
(Q::MPolyQuo)(a) = MPolyQuoElem(Q.R(a), Q)

zero(Q::MPolyQuo) = Q(0)
one(Q::MPolyQuo) = Q(1)

function isinvertible_with_inverse(a::MPolyQuoElem)
  Q = parent(a)
  I = Q.I
  if isdefined(I, :gb)
    J = I.gb.O
  else
    J = gens(I)
  end
  J = vcat(J, [a.f])
  H, T = groebner_basis_with_transform(ideal(J))
  if 1 in H
    @assert nrows(T) == 1
    return true, Q(T[1, end])
  end
  return false, a
end

isunit(a::MPolyQuoElem) = isinvertible_with_inverse(a)[1]
function inv(a::MPolyQuoElem)
  fl, b = isinvertible_with_inverse(a)
  fl || error("Element not invertible")
  return b
end

"""
Tries to write the generators of `M` as linear combinations of generators in `SM`.
Extremely low level, might migrate to Singular.jl and be hidd...
"""
function lift(M::Singular.sideal, SM::Singular.sideal)
  R = base_ring(M)
  ptr,rest_ptr = Singular.libSingular.id_Lift(M.ptr, SM.ptr, R.ptr)
  return Singular.Module(R, ptr), Singular.Module(R,rest_ptr)
end

"""
Converts a sparse-Singular vector of polynomials to an Oscar sparse row.
"""
function sparse_row(R::MPolyRing, M::Singular.svector{<:Singular.spoly})
  v = Dict{Int, MPolyBuildCtx}()
  for (i, e, c) = M
    if !haskey(v, i)
      v[i] = MPolyBuildCtx(R)
    end
    push_term!(v[i], base_ring(R)(c), e)
  end
  sparse_row(R, [(k,finish(v)) for (k,v) = v])
end

"""
Converts a sparse-Singular vector of polynomials to an Oscar sparse row.
Collect only the column indices in `U`.
"""
function sparse_row(R::MPolyRing, M::Singular.svector{<:Singular.spoly}, U::UnitRange)
  v = Dict{Int, MPolyBuildCtx}()
  for (i, e, c) = M
    (i in U) || continue
    if !haskey(v, i)
      v[i] = MPolyBuildCtx(R)
    end
    push_term!(v[i], base_ring(R)(c), e)
  end
  sparse_row(R, [(k,finish(v)) for (k,v) = v])
end

"""
Converts the sparse-Singular matrix (`Module`) row by row to an Oscar sparse-matrix.
Only the row indeces (generators) in `V` and the column indeces in `U` are converted.
"""
function sparse_matrix(R::MPolyRing, M::Singular.Module, V::UnitRange, U::UnitRange)
  S = sparse_matrix(R)
  for g = 1:Singular.ngens(M)
    (g in V) || continue
    push!(S, sparse_row(R, M[g], U))
  end
  return S
end

"""
Converts the sparse-Singular matrix (`Module`) row by row to an Oscar sparse-matrix.
"""
function sparse_matrix(R::MPolyRing, M::Singular.Module)
  S = sparse_matrix(R)
  for g = 1:Singular.ngens(M)
    push!(S, sparse_row(R, M[g]))
  end
  return S
end

"""
Converts the sparse-Singular matrix (`Module`) row by row to an Oscar dense-matrix.
"""
function matrix(R::MPolyRing, M::Singular.Module)
  return matrix(sparse_matrix(R, M))
end

function divides(a::MPolyQuoElem, b::MPolyQuoElem)
  check_parent(a, b)
  simplify!(a) #not neccessary
  simplify!(b) #not neccessary
  iszero(b) && error("cannot divide by zero")

  Q = parent(a)
  I = Q.I
  if isdefined(I, :gb)
    J = I.gb.O
  else
    J = gens(I)
  end

  BS = BiPolyArray([a.f], keep_ordering = false)
  singular_assure(BS)

  J = vcat(J, [b.f])
  BJ = BiPolyArray(J, keep_ordering = false)
  singular_assure(BJ)

  s, = Singular.lift(BJ.S, BS.S)
  if Singular.ngens(s) < 1 || iszero(s[1])
    return false, a
  end
  return true, Q(sparse_matrix(base_ring(Q), s, 1:1, length(J):length(J))[1, length(J)])
end

#TODO: find a more descriptive, meaningful name
function _kbase(Q::MPolyQuo)
  I = Q.I
  groebner_assure(I)
  singular_assure(I.gb)
  s = Singular.kbase(I.gb.S)
  if iszero(s)
    error("ideal was no zero-dimensional")
  end
  return [Q.R(x) for x = gens(s)]
end

#TODO: the reverse map...
# problem: the "canonical" reps are not the monomials.
function vector_space(K::AbstractAlgebra.Field, Q::MPolyQuo)
  R = Q.R
  @assert K == base_ring(R)
  l = _kbase(Q)
  V = free_module(K, length(l))
  function im(a::Generic.FreeModuleElem)
    @assert parent(a) == V
    b = R(0)
    for i=1:length(l)
      c = a[i]
      if !iszero(c)
        b += c*l[i]
      end
    end
    return Q(b)
  end
  return V, MapFromFunc(im, V, Q)
end

################################################################################
#
#  To fix printing of fraction fields of MPolyQuo
#
################################################################################

function AbstractAlgebra.expressify(a::AbstractAlgebra.Generic.Frac{T};
                                    context = nothing) where {T <: MPolyQuoElem}
  n = numerator(a, false)
  d = denominator(a, false)
  if isone(d)
    return expressify(n, context = context)
  else
    return Expr(:call, ://, expressify(n, context = context), expressify(d, context = context))
  end
end
