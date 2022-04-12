%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub, uint256_unsigned_div_rem, uint256_mul, uint256_le, uint256_check, uint256_lt
from starkware.cairo.common.math import assert_not_zero

# Balancer deals with numbers by extending them with 10**18
# Extended version of a number is prefixed by "b" and referred as
# BNum through the contract

func bone() -> (base: Uint256):
    return (Uint256(10**18, 0))
end

# Converts BNum to Uint256
func btoi {range_check_ptr} (a: Uint256) -> (b: Uint256):
    alloc_locals
    let (local base) = bone()
    let (b: Uint256) = bdiv(a,base)
    return (b=b)
end

# Floors a BNum
func bfloor {range_check_ptr} (a: Uint256) -> (b: Uint256):
    alloc_locals
    # First divide by bone than multiply by it
    let (local down_scaled: Uint256) = btoi(a)
    let (local base) = bone()

    # Currently only taking the top
    let (local result: Uint256) = bmul(down_scaled, base)
    return(b=result)
end

# Adds a to b, reverts if there's an overflow
func badd {range_check_ptr} (a: Uint256, b: Uint256) -> (r: Uint256):
    alloc_locals
    let (result: Uint256, carry: felt) = uint256_add(a,b)
    
    with_attr error_msg("Overflow on badd"):
        assert carry = 0
    end

    return (r=result)
end

# Subtracts a from b, reverts if b > a
func bsub {range_check_ptr} (a: Uint256, b: Uint256) -> (r: Uint256):
    let (result: Uint256, flag) = bsub_sign(a,b)
    with_attr error_msg("Underflow on bsub"):
        assert flag = 0
    end
    return (r=result)   
end

func bsub_sign {range_check_ptr} (
    a: Uint256, 
    b: Uint256
) -> (
    r: Uint256, 
    flag: felt
):
    alloc_locals
    let (local blea) = uint256_le(b,a)
    if blea == 1:
        let (local result: Uint256) = uint256_sub(a,b)
        return (r=result, flag=0)
    else: 
        let (local result: Uint256) = uint256_sub(b,a)
        return (r=result, flag=1)
    end 
end

func bmul {range_check_ptr} (a: Uint256, b: Uint256) -> (r: Uint256):
    # Currently only using low and reverting on overflow
    let (low: Uint256, high: Uint256) = uint256_mul(a, b)

    with_attr error_msg("Overflow on bmul"):
        assert_not_zero(high.low)
        assert_not_zero(high.high)
    end

    return(r=low)
end

func bdiv {range_check_ptr} (a: Uint256, b: Uint256) -> (r: Uint256):
    alloc_locals
    uint256_check(a)
    uint256_check(b)
    
    let (local is_zero: felt) = uint256_iszero(b)
    with_attr error_msg("Division to zero"):
        assert is_zero = 0
    end

    let (local result: Uint256, _) = uint256_unsigned_div_rem(a,b)
    return (r=result)
end

func bpowi {range_check_ptr} (a: Uint256, n: Uint256) -> (r: Uint256):
    alloc_locals
    uint256_check(a)
    uint256_check(n)

    let (_, local nmod2: Uint256) = uint256_unsigned_div_rem(n, Uint256(2,0))
    let (local is_zero: felt) = uint256_iszero(nmod2)
    if is_zero == 1:
        let (local base) = bone()
        let (local n_start) = bdiv(n, Uint256(2,0))
        return bpowi_r(a, n_start, base)
    else:
        let (local n_start) = bdiv(n, Uint256(2,0))
        return bpowi_r(a, n_start, a)
    end 
end

# Recursive part of the bpowi
func bpowi_r {range_check_ptr} (a: Uint256, n: Uint256, z: Uint256) -> (r: Uint256):
    alloc_locals

    # Exit case, if n == 0 return z
    let (is_zero: felt) = uint256_iszero(n)
    if is_zero == 1:
        return (r=z)
    end

    let (local a_next) = bmul(a, a)
    let (local n_next, local nmod2: Uint256) = uint256_unsigned_div_rem(n, Uint256(2,0))

    let (local nmod2_zero: felt) = uint256_iszero(nmod2)

    # If n%2 != 0, multiply z by a and continue the loop  
    if nmod2_zero == 0:
        let (local z_next) = bmul(z, a_next)
        return bpowi_r(a_next, n_next, z_next)
    end

    # Otherwise, leave z unchanged and continue the loop
    return bpowi_r(a_next, n_next, z)
end

func bpow_approx {range_check_ptr} (base: Uint256, exp: Uint256, precision: Uint256) -> (r: Uint256):
    alloc_locals

    # get b_one
    let (local one: Uint256) = bone()
    let (local x: Uint256, local xneg: felt) = bsub_sign(base, one)
    
    local a: Uint256 = exp
    local term: Uint256 = one

    return bpow_approx_r(i=Uint256(1,0), term=term, precision=precision, sum=term, x=x, xneg=xneg)
end

func bpow_approx_r {range_check_ptr} (
    i: Uint256,
    term: Uint256, 
    precision: Uint256, 
    sum: Uint256,
    x: Uint256,
    xneg: felt
) -> (
    r: Uint256
):
    alloc_locals
    let (local one: Uint256) = bone()
    let (local bigK: Uint256, _) = uint256_mul(i, one)
    let (local c: Uint256, local cneg: felt) = bsub_sign(bigK, one)
    let (local c2: Uint256) =  bmul(c,x)
    let (local term1: Uint256) = bmul(term, c2)  
    let (local term2: Uint256) = bmul(term1, bigK)

    # Base case where term2 == 0
    let (local term2zero: felt) = uint256_iszero(term2)
    if term2zero == 1:
        return (r=sum)
    end

    # Base case where term >= precision
    let (local t_lt_p: felt) = uint256_lt(term2, precision)
    if t_lt_p == 1:
        return (r=sum) 
    end

    # Assume i won't overflow
    let (local i1: Uint256, _) = uint256_add(i, Uint256(1,0))

    # xneg XOR cneg
    if xneg + cneg == 1:
        let (local sum1: Uint256) = bsub(sum, term2)
        return bpow_approx_r(
            i=i1, 
            term=term2, 
            precision=precision, 
            sum=sum1, 
            x=x, 
            xneg=xneg)
    else:
        let (local sum1:Uint256) = badd(sum, term2)
        return bpow_approx_r(
            i=i1,
            term=term2,
            precision=precision,
            sum=sum1,
            x=x,
            xneg=xneg) 
    end
end

# Helper method to check if a Uint256 is zero
func uint256_iszero {range_check_ptr} (a: Uint256) -> (is_zero: felt):
    alloc_locals
    
    if a.low != 0:
        return (is_zero=0)
    end

    if a.high != 0:
        return (is_zero=0)
    end

    return (is_zero=1)
end

# func calc_spot_price{
#     syscall_ptr: felt*,
#     pedersen_ptr: HashBuiltin*,
#     range_check_ptr
# }(
#     token_balance_in: Uint256,
#     token_weight_in: Uint256,
#     token_balance_out: Uint256,
#     token_weight_out: Uint256,
#     swap_fee: Uint256
# )->(
#     spot_price: Uint256
# ):
#     alloc_locals
#     let (local numer: Uint256, _) = uint256_unsigned_div_rem(token_balance_in, token_weight_in)
#     let (local denom: Uint256, _) = uint256_unsigned_div_rem(token_balance_out, token_weight_out)
#     let (local ratio: Uint256, _) = uint256_unsigned_div_rem(numer, denom)

#     return ()
# end

