###
# Tropical hypersurfaces in Oscar
# ===============================
###



###
# 0. Definition
# -------------
# M = typeof(min) or typeof(max):
#   min or max convention, affecting initial forms, tropical polynomial, etc.
# EMB = true or false:
#   embedded or abstract tropical hypersurface
#   embedded tropical variety = weighted polyhedral complex in euclidean space
#   abstract tropical variety = weighted hypergraph with enumerated vertices
###

@attributes mutable struct TropicalHypersurface{M,EMB} <: TropicalVarietySupertype{M,EMB}
    polyhedralComplex::PolyhedralComplex
    function TropicalHypersurface{M,EMB}(Sigma::PolyhedralComplex) where {M,EMB}
        if codim(Sigma)!=1
            error("TropicalHypersurface: input polyhedral complex not one-codimensional")
        end
        return new{M,EMB}(Sigma)
    end
end
export TropicalHypersurface

function pm_object(T::TropicalHypersurface)
    if has_attribute(T,:polymake_bigobject)
        return get_attribute(T,:polymake_bigobject)
    end
    error("pm_object(T::TropicalHypersurface): Has no polymake bigobject")
end



###
# 1. Printing
# -----------
###

function Base.show(io::IO, th::TropicalHypersurface{M, EMB}) where {M, EMB}
    if EMB
        print(io, "A $(repr(M)) tropical hypersurface embedded in $(ambient_dim(th))-dimensional Euclidian space")
    else
        print(io, "An abstract $(repr(M)) tropical hypersurface of dimension $(dim(th))")
    end
end



###
# 2. Basic constructors
# ---------------------
###

@doc Markdown.doc"""
    TropicalHypersurface(f::MPolyElem{TropicalSemiringElem})

Return the tropical hypersurface of a tropical polynomial.

# Examples
```jldoctest
julia> T = tropical_semiring(min)
Tropical ring (min)

julia> Txy,(x,y) = T["x","y"]
(Multivariate Polynomial Ring in x, y over Tropical ring (min), AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(min)}}[x, y])

julia> f = x+y+1
x + y + (1)

julia> Tf = TropicalHypersurface(f)
A min tropical hypersurface embedded in 2-dimensional Euclidian space
```
"""
function TropicalHypersurface(
    f::Union{AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(min)}},
             AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(max)}}}
        )
    if total_degree(f) <= 0
        error("Tropical hypersurfaces of constant polynomials not supported.")
    end
    M = convention(base_ring(f))

    fstr = Tuple(tropical_polynomial_to_polymake(f))
    pmpoly = Polymake.common.totropicalpolynomial(fstr...)
    pmhypproj = Polymake.tropical.Hypersurface{M}(POLYNOMIAL=pmpoly)
    pmhyp = Polymake.tropical.affine_chart(pmhypproj)

    Vf = TropicalHypersurface{M, true}(PolyhedralComplex(pmhyp))
    w = pmhypproj.WEIGHTS
    set_attribute!(Vf,:polymake_bigobject,pmhypproj)
    set_attribute!(Vf,:tropical_polynomial,f)
    set_attribute!(Vf,:weights,w)
    return Vf
end

# @doc Markdown.doc"""
#     tropical_variety(f::Union{AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(min)}},
#                               AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(max)}}})

# Return the tropical variety of a tropical polynomial in form of a TropicalHypersurface

# # Examples
# ```jldoctest
# julia> T = tropical_semiring(min)
# Tropical ring (min)

# julia> Txy,(x,y) = T["x","y"]
# (Multivariate Polynomial Ring in x, y over Tropical ring (min), AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(min)}}[x, y])

# julia> f = x+y+1
# x + y + (1)

# julia> Tf = TropicalHypersurface(f)
# A min tropical hypersurface embedded in 2-dimensional Euclidian space
# ```
# """
# function tropical_variety(f::Union{AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(min)}},
#                                    AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(max)}}})
#     return TropicalHypersurface(f)
# end


@doc Markdown.doc"""
    TropicalHypersurface{M}(f::Union{AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(min)}},
                                     AbstractAlgebra.Generic.MPoly{Oscar.TropicalSemiringElem{typeof(max)}}})

Return the tropical hypersurface of an algebraic polynomial.
If M=min, the tropical hypersurface will obey the min-convention.
If M=max, the tropical hypersurface will obey the max-convention.
If coefficient ring has a valuation, the tropical hypersurface will be constructed with respect to it.
If coefficient ring has no valuation, the tropical hypersurface will be constructed with respect to the trivial valuation.

# Examples
julia> K = PadicField(7, 2)

julia> Kxy, (x,y) = K["x", "y"]

julia> f = 7*x+y+49

julia> TropicalHypersurface(f, min)

julia> TropicalHypersurface(f, max)
"""
function TropicalHypersurface(f::AbstractAlgebra.Generic.MPoly{<:RingElement},M::Union{typeof(min),typeof(max)}=min)
    tropf = tropical_polynomial(f,M)
    Tf = TropicalHypersurface(tropf)
    w = pm_object(Tf).WEIGHTS
    set_attribute!(Tf,:algebraic_polynomial,f)
    set_attribute!(Tf,:tropical_polynomial,tropf)
    set_attribute!(Tf,:weights,w)
  return Tf
end


function TropicalHypersurface(f::AbstractAlgebra.Generic.MPoly{<:RingElement}, val::TropicalSemiringMap, M::Union{typeof(min),typeof(max)}=min)
    tropf = tropical_polynomial(f,val,M)
    Tf = TropicalHypersurface(tropf)
    w = pm_object(Tf).WEIGHTS
    set_attribute!(Tf,:algebraic_polynomial,f)
    set_attribute!(Tf,:tropical_polynomial,tropf)
    set_attribute!(Tf,:weights,w)
  return Tf
end


# @doc Markdown.doc"""
#     tropical_variety(f::AbstractAlgebra.Generic.MPoly{<:RingElement}, M::Union{typeof(min),typeof(max)})

# Return the tropical variety of an algebraic polynomial in the form of a TropicalHypersurface.
# If M=min, the tropical hypersurface will obey the min-convention.
# If M=max, the tropical hypersurface will obey the max-convention.
# If coefficient ring has a valuation, the tropical hypersurface will be constructed with respect to it.
# If coefficient ring has no valuation, the tropical hypersurface will be constructed with respect to the trivial valuation.
# The function is the same as TropicalHypersurface{M}(f).

# # Examples
# julia> K = PadicField(7, 2)

# julia> Kxy, (x,y) = K["x", "y"]

# julia> f = 7*x+y+49

# julia> tropical_variety(f,min)

# julia> tropical_variety(f,max)
# """
# function tropical_variety(f::AbstractAlgebra.Generic.MPoly{<:RingElement}, M::Union{typeof(min),typeof(max)})
#     return TropicalHypersurface{M}(f)
# end



###
# 3. Basic properties
# -------------------
###

# todo: add examples for varieties, curves and linear spaces
@doc Markdown.doc"""
    dual_subdivision(TH::TropicalHypersurface{M, EMB})

Return the dual subdivision of `TH` if it is embedded. Otherwise an error is thrown.

# Examples
A tropical hypersurface in RR^n is always of dimension n-1
```jldoctest
julia> T = tropical_semiring(min);

julia> Txy,(x,y) = T["x","y"];

julia> f = x+y+1;

julia> tropicalLine = TropicalHypersurface(f);

julia> dual_subdivision(tropicalLine)
A subdivision of points in ambient dimension 3
```
"""
function dual_subdivision(TH::TropicalHypersurface{M,EMB}) where {M,EMB}
    # not sure whether it makes sense to support abstract tropical hypersurfaces, but it can't hurt to check
    if !EMB
        error("tropical hypersurface not embedded")
    end

    return SubdivisionOfPoints(pm_object(TH).DUAL_SUBDIVISION)
end
export dual_subdivision


@doc Markdown.doc"""
    polynomial(TH::TropicalHypersurface{M, EMB})

Return the tropical polynomial of `TH` if it is embedded. Otherwise an error is thrown.

# Examples
```jldoctest
julia> T = tropical_semiring(min);

julia> Txy,(x,y) = T["x","y"];

julia> f = x+y+1;

julia> TH = TropicalHypersurface(f);

julia> polynomial(TH)
x + y + (1)
```
"""
function polynomial(TH::TropicalHypersurface{M,EMB}) where {M,EMB}
    if !EMB
        error("tropical hypersurface not embedded")
    end
    return get_attribute(TH,:tropical_polynomial)
end
export polynomial
