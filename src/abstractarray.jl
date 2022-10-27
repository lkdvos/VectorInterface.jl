# Vector interface implementation for subtypes of `AbstractArray`
##################################################################

# scalartype
#------------
scalartype(::Type{A}) where {T, A<:AbstractArray{T}} = scalartype(T) # recursive

# zerovector & zerovector!!
#---------------------------
function zerovector(x::AbstractArray, ::Type{S} = scalartype(x)) where {S<:Number}
    return zerovector.(x, S)
end

function zerovector!(x::AbstractArray{<:Number}, ::Type{S} = scalartype(x)) where {S<:Number}
    if scalartype(x) !== S
        throw(ArgumentError("cannot make a zero vector with scalar type $S in-place in an object of type $(typeof(x))"))
    else
        return fill!(x, zero(S))
    end
end
function zerovector!(x::AbstractArray, ::Type{S} = scalartype(x)) where {S<:Number}
    if scalartype(x) !== S
        throw(ArgumentError("cannot make a zero vector with scalar type $S in-place in an object of type $(typeof(x))"))
    else
        x .= zerovector!!.(x, S)
        return x
    end
end

function zerovector!!(x::AbstractArray{S}, ::Type{S} = scalartype(x)) where {S<:Number}
    return fill!(x, zero(S))
end
function zerovector!!(x::AbstractArray, ::Type{S} = scalartype(x)) where {S<:Number}
    if scalartype(x) !== S
        return zerovector!!.(x, S)
    else
        x .= zerovector!!.(x, S)
        return x
    end
end

# scale, scale! & scale!!
#-------------------------
scale(x::AbstractArray, α::Number) = scale.(x, α)

function scale!(x::AbstractArray{T}, α::Number) where {T<:BlasFloat}
    LinearAlgebra.rmul!(x, convert(T, α))
    return x
end
function scale!(x::AbstractArray, α::Number)
    x .= scale!!.(x, α)
    return x
end
function scale!(y::AbstractArray{T}, x::AbstractArray, α::Number) where {T<:BlasFloat}
    LinearAlgebra.mul!(y, x, convert(T, α))
    return y
end
function scale!(y::AbstractArray, x::AbstractArray, α::Number)
    y .= scale!!.(y, x, α)
    return y
end

function scale!!(x::AbstractArray, α::Number)
    T = scalartype(x)
    if promote_type(T, typeof(α)) <: T
        return scale!(x, α)
    else
        return scale!!.(x, α)
    end
end
function scale!!(y::AbstractArray, x::AbstractArray, α::Number)
    T = scalartype(y)
    if promote_type(T, typeof(α), scalartype(x)) <: T
        return scale!(y, x, α)
    else
        return scale!!.(y, x, α)
    end
end

# add, add! & add!!
#-------------------
function add(y::AbstractArray, x::AbstractArray, α::ONumber = _one, β::ONumber = _one)
    ax = axes(x)
    ay = axes(y)
    ax == ay || throw(DimensionMismatch("Output axes $ay differ from input axes $ax"))
    return add.(y, x, (α,), (β,))
end

# Special case: simple numerical arrays with BLAS-compatible floating point type
function add!(y::AbstractArray{T}, x::AbstractArray{T},
                α::ONumber = _one, β::_One = _one) where {T<:BlasFloat}
    LinearAlgebra.axpy!(convert(T, α), x, y)
    return y
end
function add!(y::AbstractArray{T}, x::AbstractArray{T},
                α::ONumber, β::Number) where {T<:BlasFloat}
    LinearAlgebra.axpby!(convert(T, α), x, convert(T, β), y)
    return y
end
# General case:
function add!(y::AbstractArray, x::AbstractArray, α::ONumber = _one, β::ONumber = _one)
    ax = axes(x)
    ay = axes(y)
    ax == ay || throw(DimensionMismatch("Output axes $ay differ from input axes $ax"))
    y .= add!!.(y, x, (α,), (β,)) # might error
    return y
end

function add!!(y::AbstractArray, x::AbstractArray, α::ONumber = _one, β::ONumber = _one)
    T = scalartype(y)
    if promote_type(T, typeof(α), typeof(β), scalartype(x)) <: T
        return add!(y, x, α, β)
    else
        ax = axes(x)
        ay = axes(y)
        ax == ay || throw(DimensionMismatch("Output axes $ay differ from input axes $ax"))
        return add!!.(y, x, (α,), (β,))
    end
end

# inner
#-------
inner(x::AbstractArray{<:Number}, y::AbstractArray{<:Number}) = LinearAlgebra.dot(x, y)
function inner(x::AbstractArray, y::AbstractArray)
    ax = axes(x)
    ay = axes(y)
    ax == ay || throw(DimensionMismatch("Non-matching axes $ax and $ay"))
    T = promote_type(scalartype(x), scalartype(y))
    s::T = zero(T)
    for I in eachindex(x)
        s += inner(x[I], y[I])
    end
    return s
end
