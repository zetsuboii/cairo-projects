%lang starknet

# Cairo's felt is int252, so in order to handle uint256
# healthily, this struct is used. It's implementation is
# simply two fields of 128 bits represented as low and high
# https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/uint256.cairo
# Repo also has some Uint256 operations 
from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace ERC20:
    # There's no need for decorators in interfaces
    # Also, inheriting contract won't use this interface

    ################################################################
    ########################### STORAGE  ###########################
    ################################################################

    func name() -> (name: felt):
    end

    func symbol() -> (symbol: felt):
    end

    func decimals() -> (decimals: felt):
    end

    func totalSupply() -> (decimals: felt):
    end

    func balanceOf(account: felt) -> (balance: felt):
    end

    func allowance(owner: felt, spender: felt) -> (allowance: felt):
    end

    ################################################################
    ########################## FUNCTIONS ###########################
    ################################################################

    func transfer(recipient:felt, amount:felt) -> (success:felt):
    end

    func transferFrom(
        sender: felt,
        recipient: felt,
        amount: felt,
    ) -> (success: felt):
    end

    func approve(spender: felt, amount: felt) -> (success: felt):
    end
end