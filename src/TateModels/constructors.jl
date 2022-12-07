################################################
# 1: The Julia types for GlobalTateModel
################################################

@attributes mutable struct GlobalTateModel
    a1::MPolyElem{fmpq}
    a2::MPolyElem{fmpq}
    a3::MPolyElem{fmpq}
    a4::MPolyElem{fmpq}
    a6::MPolyElem{fmpq}
    pt::MPolyElem{fmpq}
    toric_base_space::Oscar.AbstractNormalToricVariety
    toric_ambient_space::Oscar.AbstractNormalToricVariety
    Y4::Oscar.ClosedSubvarietyOfToricVariety
    function GlobalTateModel(a1::MPolyElem{fmpq},
                            a2::MPolyElem{fmpq},
                            a3::MPolyElem{fmpq},
                            a4::MPolyElem{fmpq},
                            a6::MPolyElem{fmpq},
                            pt::MPolyElem{fmpq},
                            toric_base_space::Oscar.AbstractNormalToricVariety,
                            toric_ambient_space::Oscar.AbstractNormalToricVariety,
                            Y4::Oscar.ClosedSubvarietyOfToricVariety)
        return new(a1, a2, a3, a4, a6, pt, toric_base_space, toric_ambient_space, Y4)
    end
end
export GlobalTateModel


################################################
# 2: Constructors over specified bases
################################################

@doc Markdown.doc"""
    GenericGlobalTateModel(base::Oscar.AbstractNormalToricVariety)

This method constructs a global Tate model over a given toric base
3-fold. The Tate sections ``a_i`` are taken with (pseudo) random coefficients.

# Examples
```jldoctest
julia> using Oscar

julia> t = GlobalTateModel(TestBase())
A global Tate model over a concrete base

julia> is_smooth(toric_ambient_space(t))
false
```
"""
function GlobalTateModel(base::Oscar.AbstractNormalToricVariety)
    toric_ambient_space = _ambient_space_from_base(base)
    (a1, a2, a3, a4, a6, pt) = _tate_polynomial(base, toric_ambient_space)
    Y4 = Oscar.ClosedSubvarietyOfToricVariety(toric_ambient_space, [pt])
    model = GlobalTateModel(a1, a2, a3, a4, a6, pt, base, toric_ambient_space, Y4)
    set_attribute!(model, :base_fully_specified, true)
    return model
end
export GlobalTateModel


@doc Markdown.doc"""
    GlobalTateModelOverProjectiveSpace()

This method constructs a global Tate model over the 3-dimensional projective space.

# Examples
```jldoctest
julia> using Oscar

julia> GlobalTateModelOverProjectiveSpace()
A global Tate model over a concrete base
```
"""
GlobalTateModelOverProjectiveSpace() = GlobalTateModel(projective_space(NormalToricVariety,3))
export GlobalTateModelOverProjectiveSpace


@doc Markdown.doc"""
    SpecificGlobalTateModel(ais::Vector{MPolyElem_dec{fmpq, fmpq_mpoly}}, base::Oscar.AbstractNormalToricVariety)

This method operates analogously to `GenericGlobalTateModel(base::Oscar.AbstractNormalToricVariety)`.
The only difference is that the Tate sections ``a_i`` can be specified with non-generic values.

# Examples
```jldoctest
julia> using Oscar

julia> base = TestBase()
A normal toric variety

julia> a1 = sum([rand(Int) * b for b in basis_of_global_sections(anticanonical_bundle(base))]);

julia> a2 = sum([rand(Int) * b for b in basis_of_global_sections(anticanonical_bundle(base)^2)]);

julia> a3 = sum([rand(Int) * b for b in basis_of_global_sections(anticanonical_bundle(base)^3)]);

julia> a4 = sum([rand(Int) * b for b in basis_of_global_sections(anticanonical_bundle(base)^4)]);

julia> a6 = sum([rand(Int) * b for b in basis_of_global_sections(anticanonical_bundle(base)^6)]);

julia> t = GlobalTateModel([a1, a2, a3, a4, a6], base)
A global Tate model over a concrete base

julia> is_smooth(toric_ambient_space(t))
false
```
"""
function GlobalTateModel(ais::Vector{MPolyElem_dec{fmpq, fmpq_mpoly}}, base::Oscar.AbstractNormalToricVariety)
    if length(ais) != 5
        throw(ArgumentError("We require exactly 5 Tate section"))
    end
    if any(k -> parent(k) != cox_ring(base), ais)
        throw(ArgumentError("All Tate sections must reside in the Cox ring of the base toric variety"))
    end
    toric_ambient_space = _ambient_space_from_base(base)
    (a1, a2, a3, a4, a6, pt) = _tate_polynomial(base, toric_ambient_space, ais)
    Y4 = Oscar.ClosedSubvarietyOfToricVariety(toric_ambient_space, [pt])
    model = GlobalTateModel(a1, a2, a3, a4, a6, pt, base, toric_ambient_space, Y4)
    set_attribute!(model, :base_fully_specified, true)
    return model
end
export GlobalTateModel


################################################
# 3: Constructors over not fully specified bases
################################################

@doc Markdown.doc"""
    GlobalTateModel(ais::Vector{fmpq_mpoly}, auxiliary_base_ring::MPolyRing)

This method constructs a global Tate model over a base space that is not
fully specified. The following example exemplifies this approach.

# Examples
```jldoctest
julia> using Oscar

julia> auxiliary_base_ring, (a10,a21,a32,a43,a65,w) = QQ["a10", "a21", "a32", "a43", "a65", "w"];

julia> a1 = a10;

julia> a2 = a21 * w;

julia> a3 = a32 * w^2;

julia> a4 = a43 * w^3;

julia> a6 = a65 * w^5;

julia> ais = [a1, a2, a3, a4, a6];

julia> t = GlobalTateModel(ais, auxiliary_base_ring)
A global Tate model over a not fully specified base

julia> tate_polynomial(t)
-a10*x*y*z + a21*w*x^2*z^2 - a32*w^2*y*z^3 + a43*w^3*x*z^4 + a65*w^5*z^6 + x^3 - y^2

julia> toric_base_space(t)
A normal, affine, 6-dimensional toric variety

julia> toric_ambient_space(t)
A normal, simplicial toric variety

julia> dim(toric_ambient_space(t))
8
```
"""
function GlobalTateModel(ais::Vector{fmpq_mpoly}, auxiliary_base_ring::MPolyRing)
    if length(ais) != 5
        throw(ArgumentError("We expect exactly 5 Tate sections"))
    end
    if any(k -> parent(k) != auxiliary_base_ring, ais)
        throw(ArgumentError("All Tate sections must reside in the provided auxiliary base ring"))
    end
    auxiliary_base_space = affine_space(NormalToricVariety, length(gens(auxiliary_base_ring)))
    set_coordinate_names(auxiliary_base_space, [string(k) for k in gens(auxiliary_base_ring)])
    auxiliary_ambient_space = _ambient_space_from_base(auxiliary_base_space)
    (a1, a2, a3, a4, a6, pt) = _tate_polynomial(auxiliary_base_space, auxiliary_ambient_space, ais)
    Y4 = Oscar.ClosedSubvarietyOfToricVariety(auxiliary_ambient_space, [pt])
    model = GlobalTateModel(a1, a2, a3, a4, a6, pt, auxiliary_base_space, auxiliary_ambient_space, Y4)
    set_attribute!(model, :base_fully_specified, false)
    return model
end
export GlobalTateModel


################################################
# 4: Display
################################################

function Base.show(io::IO, t::GlobalTateModel)
    if base_fully_specified(t)
        join(io, "A global Tate model over a concrete base")
    else
        join(io, "A global Tate model over a not fully specified base")
    end
end
