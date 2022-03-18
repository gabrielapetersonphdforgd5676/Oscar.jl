###
# Tropical curves in Oscar
###



###
# 1. Definition
# -------------
# M = typeof(min) or typeof(max):
#   min or max convention, affecting initial ideals
# EMB = true or false:
#   embedded or abstract tropical curves
#   embedded tropical variety = graph embedded in euclidean space with weighted edges and vertices
#   abstract tropical variety = graph with enumerated vertices with weighted edges and vertices
###

@attributes mutable struct TropicalCurve{M,EMB} <: TropicalVarietySupertype{M,EMB}
    polyhedralComplex::PolyhedralComplex
    function TropicalCurve{M,EMB}(Sigma::PolyhedralComplex) where {M,EMB}
        if dim(Sigma)!=1
            error("TropicalCurve: input polyhedral complex not one-dimensional")
        end
        return new{M,EMB}(Sigma)
    end
end
export TropicalCurve

function pm_object(T::TropicalCurve)
    if has_attribute(T,:polymake_bigobject)
        return get_attribute(T,:polymake_bigobject)
    end
    error("pm_object(T::TropicalCurve): Has no polymake bigobject")
end


###
# 2. Basic constructors
# ---------------------
###

@doc Markdown.doc"""
    TropicalCurve{M, EMB}()

Construct a tropical curve from a list of edges and a vector of their lengths.
If the curve is embedded, vertices must be points in $\mathbb R^n$.
If the curve is abstract, vertices must be 1, ..., n.

# Examples

"""
function TropicalCurve{M, EMB}(Vertices::Union{SubObjectIterator{<:RayVector}, Oscar.MatElem, AbstractMatrix}, LS::Union{Oscar.MatElem, AbstractMatrix}, Incidence::Matrix{Bool}) where {M, EMB}
    error("TODO: not yet implemented")
    if EMB
        # tropicalCurve = TropicalCurve(PolyhedralComplex(Vertices, LS, IncidenceMatrix(Polymake.IncidenceMatrix(Incidence))))
        return #...
    else
        return #...
    end
end



###
# 3. Basic properties
# -------------------
###
