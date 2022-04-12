%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import (
    Uint256, 
    uint256_add, 
    uint256_sub, 
    uint256_mul, 
    uint256_le, 
    uint256_lt,
    uint256_check, 
    uint256_unsigned_div_rem
) 

#	██████╗ ███╗   ██╗██╗   ██╗███╗   ███╗
#	██╔══██╗████╗  ██║██║   ██║████╗ ████║
#	██████╔╝██╔██╗ ██║██║   ██║██╔████╔██║
#	██╔══██╗██║╚██╗██║██║   ██║██║╚██╔╝██║
#	██████╔╝██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
#	╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
#   Balancer Number: 
#   Balancer deals with numbers by extending them with 10**18
#   This file includes some operations involving this extended number
#   Through the project this number is referred as "BNum"

namespace BNum:
    func b_one() -> (base: Uint256):
        return (Uint256(10**18, 0))
    end

    func MIN_BPOW_BASE() -> (r: Uint256):
        return Uint256(1, 0)
    end

    func MAX_BPOW_BASE() -> (r: Uint256):
        let (twobone: Uint256) = uint256_mul((b_one()), Uint256(2,0))
        return uint256_sub(twobone, 1)
    end

    func BPOW_PRECISION() -> ():
        return Uint256(10**8, 0)
    end

    # Converts BNum to Uint256
    func toi {range_check_ptr} (a: Uint256) -> (b: Uint256):
        alloc_locals
        let (local base) = b_one()
        let (b: Uint256) = div(a,base)
        return (b=b)
    end

    # Floors a BNum
    func floor {range_check_ptr} (a: Uint256) -> (b: Uint256):
        alloc_locals
        # First divide by b_one than multiply by it
        let (local down_scaled: Uint256) = toi(a)
        let (local base) = b_one()

        # Currently only taking the top
        let (local result: Uint256) = mul(down_scaled, base)
        return(b=result)
    end

    # Adds a to b, reverts if there's an overflow
    func add {range_check_ptr} (a: Uint256, b: Uint256) -> (r: Uint256):
        alloc_locals
        let (result: Uint256, carry: felt) = uint256_add(a,b)
        
        with_attr error_msg("Overflow on add"):
            assert carry = 0
        end

        return (r=result)
    end

    # Subtracts a from b, reverts if b > a
    func sub {range_check_ptr} (a: Uint256, b: Uint256) -> (r: Uint256):
        let (result: Uint256, flag) = sub_sign(a,b)
        with_attr error_msg("Underflow on sub"):
            assert flag = 0
        end
        return (r=result)   
    end

    func sub_sign {range_check_ptr} (
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

    func mul {range_check_ptr} (a: Uint256, b: Uint256) -> (r: Uint256):
        # Currently only using low and reverting on overflow
        let (low: Uint256, high: Uint256) = uint256_mul(a, b)

        with_attr error_msg("Overflow on mul"):
            assert_not_zero(high.low)
            assert_not_zero(high.high)
        end

        return(r=low)
    end

    func div {range_check_ptr} (a: Uint256, b: Uint256) -> (r: Uint256):
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

    func powi {range_check_ptr} (a: Uint256, n: Uint256) -> (r: Uint256):
        alloc_locals
        uint256_check(a)
        uint256_check(n)

        let (_, local nmod2: Uint256) = uint256_unsigned_div_rem(n, Uint256(2,0))
        let (local is_zero: felt) = uint256_iszero(nmod2)
        if is_zero == 1:
            let (local base) = b_one()
            let (local n_start) = div(n, Uint256(2,0))
            return _powi(a, n_start, base)
        else:
            let (local n_start) = div(n, Uint256(2,0))
            return _powi(a, n_start, a)
        end 
    end

    # Recursive part of the powi
    func _powi {range_check_ptr} (a: Uint256, n: Uint256, z: Uint256) -> (r: Uint256):
        alloc_locals

        # Exit case, if n == 0 return z
        let (is_zero: felt) = uint256_iszero(n)
        if is_zero == 1:
            return (r=z)
        end

        let (local a_next) = mul(a, a)
        let (local n_next, local nmod2: Uint256) = uint256_unsigned_div_rem(n, Uint256(2,0))

        let (local nmod2_zero: felt) = uint256_iszero(nmod2)

        # If n%2 != 0, multiply z by a and continue the loop  
        if nmod2_zero == 0:
            let (local z_next) = mul(z, a_next)
            return _powi(a_next, n_next, z_next)
        end

        # Otherwise, leave z unchanged and continue the loop
        return _powi(a_next, n_next, z)
    end

    func pow_approx {range_check_ptr} (base: Uint256, exp: Uint256, precision: Uint256) -> (r: Uint256):
        alloc_locals

        # get b_one
        let (local bone: Uint256) = b_one()
        let (local x: Uint256, local xneg: felt) = sub_sign(base, bone)
        
        local a: Uint256 = exp
        local term: Uint256 = bone

        return _pow_approx(
            i=Uint256(1,0), 
            term=term, 
            precision=precision, 
            sum=term, 
            x=x, 
            xneg=xneg)
    end

    func _pow_approx {range_check_ptr} (
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
        let (local bone: Uint256) = b_one()
        let (local bigK: Uint256, _) = uint256_mul(i, bone)
        let (local c: Uint256, local cneg: felt) = sub_sign(bigK, bone)
        let (local c2: Uint256) =  mul(c,x)
        let (local term1: Uint256) = mul(term, c2)  
        let (local term2: Uint256) = mul(term1, bigK)

        # Base case where term2 == 0
        let (local term2zero: felt) = uint256_iszero(term2)
        if term2zero == 1:
            return (r=sum)
        end

        # Base case where term2 >= precision
        let (local p_lt_t: felt) = uint256_lt(precision, term2)
        if p_lt_t == 1:
            return (r=sum) 
        end

        # Assume i won't overflow
        let (local i1: Uint256, _) = uint256_add(i, Uint256(1,0))

        # xneg XOR cneg
        if xneg + cneg == 1:
            let (local sum1: Uint256) = sub(sum, term2)
            return _pow_approx(
                i=i1, 
                term=term2, 
                precision=precision, 
                sum=sum1, 
                x=x, 
                xneg=xneg)
        else:
            let (local sum1:Uint256) = add(sum, term2)
            return _pow_approx(
                i=i1,
                term=term2,
                precision=precision,
                sum=sum1,
                x=x,
                xneg=xneg) 
        end
    end

    # Takes 
    func pow {range_check_ptr} (base: Uint256, exp: Uint256) -> (r: Uint256):
        alloc_locals

        let (base_too_low) = uint256_lt(base, (MIN_BPOW_BASE()))
        with_attr error_msg("bpow base is too low"):
            assert base_too_low = 0
        end
        
        let (base_too_high) = uint256_lt((MAX_BPOW_BASE()), base)
        with_attr error_msg("bpow base is too high"):
            assert base_too_high = 0
        end

        let (local whole: Uint256) = floor(exp)
        let (local remain: Uint256) = sub(exp, whole)
        
        let (local whole_pow) = powi(base, (toi(whole)))

        if (uint256_iszero(remain)) == 0:
            return (r=whole_pow)
        end

        let (local partial_result: Uint256) = pow_approx(
            base=base, 
            exp=remain, 
            precision=(BPOW_PRECISION())
        )

        return mul(whole_pow, partial_result) 
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