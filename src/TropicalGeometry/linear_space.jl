###
# Tropical linear spaces in Oscar
# ===============================
###



###
# 1. Definition
# -------------
# M = typeof(min) or typeof(max):
#   min or max convention, affecting initial ideals, Pluecker vector, etc.
# EMB = true or false:
#   embedded or abstract tropical linear space
#   embedded tropical linear space = weighted polyhedral complex in euclidean space
#   abstract tropical linear space = weighted hypergraph with enumerated vertices
###

@attributes mutable struct TropicalLinearSpace{M,T} <: TropicalVarietySupertype{M,T}
    # GapTV::GapObj
    polymakeTV::Polymake.BigObject
end
export TropicalLinearSpace



###
# 2. Basic constructors
# ---------------------
###

@doc Markdown.doc"""
    TropicalLinearSpace(ideal::MPolyIdeal{fmpq_poly})

Construct a tropical linear space from a degree 1 polynomial ideal

# Examples
"""
function TropicalLinearSpace(ideal::MPolyIdeal{fmpq_poly})
    error("TODO: Not implemented yet.")
    return #...
end


@doc Markdown.doc"""
    TropicalLinearSpace(plv::Vector)

Construct a tropical linear space from its Pluecker vector

# Examples
"""
function TropicalLinearSpace(plv::Vector)
    error("TODO: Not implemented yet.")
    return #...
end



###
# 3. Basic properties
# -------------------
###
