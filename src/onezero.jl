"""
    struct One end

Singleton type for representing a hard-coded constant 1 in vector addition / linear
combinations.
"""
struct One <: Number end

"""
    struct Zero end
    
Singleton type for representing a hard-coded constant 0 in vector addition / linear
combinations.
"""
struct Zero <: Number end

# Base Arithmetic
# ---------------

Base.:(-)(::One) = -1
Base.:(-)(::Zero) = Zero()
Base.:(+)(::Zero, x::Number) = x
Base.:(+)(x::Number, ::Zero) = x
Base.:(+)(::Zero, ::Zero) = Zero()

Base.:(*)(::One, x::Number) = x
Base.:(*)(::Zero, ::Number) = zero(x)
Base.:(*)(x::Number, ::One) = x
Base.:(*)(::Number, ::Zero) = zero(x)
Base.:(*)(::Zero, ::Zero) = Zero()
Base.:(*)(::One, ::One) = One()
Base.:(*)(::Zero, ::One) = Zero()
Base.:(*)(::One, ::Zero) = Zero()
Base.inv(::One) = One()

Base.conj(::One) = One()
Base.conj(::Zero) = Zero()

Base.one(::Type{One}) = One()
Base.one(::Type{Zero}) = One()
Base.one(::Union{Zero,One}) = One()
Base.zero(::Type{One}) = Zero()
Base.zero(::Type{Zero}) = Zero()
Base.zero(::Union{Zero,One}) = Zero()

Base.:(==)(::One, ::One) = true
Base.:(==)(::Zero, ::Zero) = true
Base.:(==)(::One, ::Zero) = false
Base.:(==)(::Zero, ::One) = false

# Promotion
# ---------
Base.promote_rule(::Type{One}, ::Type{T}) where {T<:Number} = T
Base.promote_rule(::Type{Zero}, ::Type{T}) where {T<:Number} = T
Base.convert(::Type{T}, ::One) where {T<:Number} = one(T)
(T::Type{<:Number})(::One) = one(T)
Base.convert(::Type{T}, ::Zero) where {T<:Number} = zero(T)
(T::Type{<:Number})(::Zero) = zero(T)
