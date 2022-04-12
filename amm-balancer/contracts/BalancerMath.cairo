%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub, uint256_unsigned_div_rem, uint256_mul, uint256_le, uint256_check
from starkware.cairo.common.math import assert_not_zero

# Balancer deals with numbers by extending them with 10**18
# Extended version of a number is prefixed by "b" and referred as
# BNum through the contract

func bbase() -> (base: Uint256):
    return (Uint256(10**18, 0))
end

# Converts BNum to Uint256
func btoi {range_check_ptr} (a: Uint256) -> (b: Uint256):
    alloc_locals
    let (local base) = bbase()
    let (b: Uint256) = bdiv(a,base)
    return (b=b)
end

# Floors a BNum
func bfloor {range_check_ptr} (a: Uint256) -> (b: Uint256):
    alloc_locals
    # First divide by bbase than multiply by it
    let (local down_scaled: Uint256) = btoi(a)
    let (local base) = bbase()

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
    
    let (local lezero: felt) = uint256_le(b, Uint256(0, 0))
    with_attr error_msg("Division to zero"):
        assert_not_zero(lezero)
    end

    let (local result: Uint256, _) = uint256_unsigned_div_rem(a,b)
    return (r=result)
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

