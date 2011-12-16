## char conversions ##

convert(::Type{Char}, x::Bool   ) = box(Char,sext32(unbox8(x)))
convert(::Type{Char}, x::Int8   ) = box(Char,sext32(unbox8(x)))
convert(::Type{Char}, x::Uint8  ) = box(Char,zext32(unbox8(x)))
convert(::Type{Char}, x::Int16  ) = box(Char,sext32(unbox16(x)))
convert(::Type{Char}, x::Uint16 ) = box(Char,zext32(unbox16(x)))
convert(::Type{Char}, x::Int32  ) = box(Char,unbox32(x))
convert(::Type{Char}, x::Uint32 ) = box(Char,unbox32(x))
convert(::Type{Char}, x::Int64  ) = box(Char,trunc32(unbox64(x)))
convert(::Type{Char}, x::Uint64 ) = box(Char,trunc32(unbox64(x)))
convert(::Type{Char}, x::Float32) = box(Char,fptoui32(unbox32(x)))
convert(::Type{Char}, x::Float64) = box(Char,fptoui32(unbox64(x)))

char(x) = convert(Char, x)

function safe_char(x)
    c = char(x)
    if '\ud800' <= c <= '\udfff' || '\U10ffff' < c
        error("invalid Unicode code point: U+", hex(c))
    end
    return c
end

integer(x::Char) = int32(x)
unsigned(x::Char) = uint32(x)

## char promotions ##

promote_rule(::Type{Char}, ::Type{Int8})   = Int32
promote_rule(::Type{Char}, ::Type{Uint8})  = Int32
promote_rule(::Type{Char}, ::Type{Int16})  = Int32
promote_rule(::Type{Char}, ::Type{Uint16}) = Int32
promote_rule(::Type{Char}, ::Type{Int32})  = Int32
promote_rule(::Type{Char}, ::Type{Uint32}) = Uint32
promote_rule(::Type{Char}, ::Type{Int64})  = Int64
promote_rule(::Type{Char}, ::Type{Uint64}) = Uint64

## character operations & comparisons ##

-(x::Char) = -int32(x)
~(x::Char) = ~int32(x)
+(x::Char, y::Char) = int32(x) + int32(y)
-(x::Char, y::Char) = int32(x) - int32(y)
*(x::Char, y::Char) = int32(x) * int32(y)
div(x::Char, y::Char) = div(int32(x), int32(y))
fld(x::Char, y::Char) = div(int32(x), int32(y))
rem(x::Char, y::Char) = rem(int32(x), int32(y))
mod(x::Char, y::Char) = rem(int32(x), int32(y))
&(x::Char, y::Char) = int32(x) & int32(y)
|(x::Char, y::Char) = int32(x) | int32(y)
($)(x::Char, y::Char) = int32(x) $ int32(y)
<<(x::Char, y::Int32) = int32(x) << y
>>(x::Char, y::Int32) = int32(x) >>> y
>>>(x::Char, y::Int32) = int32(x) >>> y
==(x::Char, y::Char) = int32(x) == int32(y)
<(x::Char, y::Char) = uint32(x) < uint32(y)
<=(x::Char, y::Char) = uint32(x) <= uint32(y)

## traits ##

sizeof(::Type{Char}) = 4

## printing & showing characters ##

print(c::Char) = (write(c); nothing)
show(c::Char) = (print('\''); print_escaped(string(c), "'"); print('\''))

## libc character class testing functions ##

iswascii(c::Char) = c < 0x80

for f = (:iswalnum, :iswalpha, :iswblank, :iswcntrl, :iswdigit,
         :iswgraph, :iswlower, :iswprint, :iswpunct, :iswspace,
         :iswupper, :iswxdigit,
         # these are BSD-only
         #:iswhexnumber, :iswideogram, :iswnumber, :iswphonogram, :iswrune, :iswspecial, 
         )
    @eval ($f)(c::Char) = bool(ccall(dlsym(libc,$expr(:quote,f)),
                                     Int32, (Char,), c))
end
