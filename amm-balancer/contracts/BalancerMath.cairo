%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_unsigned_div_rem, uint256_mul
)

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
    let (b: Uint256, _) = uint256_unsigned_div_rem(a, base)
    return (b=b)
end

# Floors a BNum
func bfloor {range_check_ptr} (a: Uint256) -> (b: Uint256):
    alloc_locals
    # First divide by bbase than multiply by it
    let (local down_scaled: Uint256) = btoi(a)
    let (local base) = bbase()
    return uint256_mul(down_scaled, base)
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

