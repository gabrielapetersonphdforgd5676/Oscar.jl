#######################################
# 1: Weierstrass sections
#######################################

@doc Markdown.doc"""
    weierstrass_section_f(w::GlobalWeierstrassModel)

Return the polynomial ``f`` used for the
construction of the global Weierstrass model.

```jldoctest
julia> using Oscar

julia> w = GlobalWeierstrassModel(TestBase())
A global Weierstrass model over a concrete base

julia> weierstrass_section_f(w);
```
"""
@attr MPolyElem{fmpq} weierstrass_section_f(w::GlobalWeierstrassModel) = w.poly_f
export weierstrass_section_f


@doc Markdown.doc"""
    weierstrass_section_g(w::GlobalWeierstrassModel)

Return the polynomial ``g`` used for the
construction of the global Weierstrass model.

```jldoctest
julia> using Oscar

julia> w = GlobalWeierstrassModel(TestBase())
A global Weierstrass model over a concrete base

julia> weierstrass_section_g(w);
```
"""
@attr MPolyElem{fmpq} weierstrass_section_g(w::GlobalWeierstrassModel) = w.poly_g
export weierstrass_section_g


#######################################
# 2: Weierstrass polynomial
#######################################

@doc Markdown.doc"""
    weierstrass_polynomial(w::GlobalWeierstrassModel)

Return the Weierstrass polynomial of the global Weierstrass model.

```jldoctest
julia> using Oscar

julia> w = GlobalWeierstrassModel(TestBase())
A global Weierstrass model over a concrete base

julia> weierstrass_polynomial(w);
```
"""
@attr MPolyElem{fmpq} weierstrass_polynomial(w::GlobalWeierstrassModel) = w.pw
export weierstrass_polynomial


#######################################
# 3: Toric spaces
#######################################

@doc Markdown.doc"""
    toric_base_space(w::GlobalWeierstrassModel)

Return the toric base space of the global Weierstrass model.

```jldoctest
julia> using Oscar

julia> w = GlobalWeierstrassModel(TestBase())
A global Weierstrass model over a concrete base

julia> is_smooth(toric_base_space(w))
true
```
"""
@attr Oscar.AbstractNormalToricVariety function toric_base_space(w::GlobalWeierstrassModel)
    base_fully_specified(w) || @info("Base space was not fully specified. Returning AUXILIARY base space.")
    return w.toric_base_space
end
export toric_base_space


@doc Markdown.doc"""
    toric_ambient_space(w::GlobalWeierstrassModel)

Return the toric base space of the global Weierstrass model.

```jldoctest
julia> using Oscar

julia> w = GlobalWeierstrassModel(TestBase())
A global Weierstrass model over a concrete base

julia> is_smooth(toric_ambient_space(w))
false
```
"""
@attr Oscar.AbstractNormalToricVariety function toric_ambient_space(w::GlobalWeierstrassModel)
    base_fully_specified(w) || @info("Base space was not fully specified. Returning AUXILIARY ambient space.")
    return w.toric_ambient_space
end
export toric_base_space


#####################################################
# 4: The CY hypersurface
#####################################################

@doc Markdown.doc"""
    cy_hypersurface(w::GlobalWeierstrassModel)

Return the Calabi-Yau hypersurface in the toric ambient space
which defines the global Weierstrass model.

```jldoctest
julia> using Oscar

julia> w = GlobalWeierstrassModel(TestBase())
A global Weierstrass model over a concrete base

julia> cy_hypersurface(w)
A closed subvariety of a normal toric variety
```
"""
@attr Oscar.ClosedSubvarietyOfToricVariety function cy_hypersurface(w::GlobalWeierstrassModel)
    base_fully_specified(w) || @info("Base space was not fully specified. Returning hypersurface in AUXILIARY ambient space.")
    return w.Y4
end
export cy_hypersurface


#####################################################
# 5: Turn global Weierstrass model into Tate model
#####################################################

# TODO: To come
# TODO: To come


#######################################
# 6: Discriminant
#######################################

@doc Markdown.doc"""
    discriminant(w::GlobalWeierstrassModel)

Return the discriminant ``\Delta = 4 f^3 + 27 g^2``.

```jldoctest
julia> using Oscar

julia> w = GlobalWeierstrassModel(TestBase())
A global Weierstrass model over a concrete base

julia> discriminant(w);
```
"""
@attr MPolyElem{fmpq} Oscar.:discriminant(w::GlobalWeierstrassModel) = 4 * w.poly_f^3 + 27 * w.poly_g^2
export discriminant
