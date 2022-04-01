%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

#////////////////////////////////////////////////#
#                    STORAGE                     #
#////////////////////////////////////////////////#

@storage_var
func Ownable_owner() -> (owner: felt):
end

#////////////////////////////////////////////////#
#                   FUNCTIONS                    #
#////////////////////////////////////////////////#

func Ownable_initializer{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(owner: felt):
    Ownable_owner.write(owner)
    return ()
end

func Ownable_only_owner{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}():
    alloc_locals
    let (owner) = Ownable_owner.read()
    let (local caller) = get_caller_address()
    
    with_attr error_message("ERR_NOT_OWNER"):
        assert caller = owner
    end

    return ()
end

func Ownable_get_owner{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (owner:felt):
    return Ownable_owner.read()
end

func Ownable_transfer_ownership{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(new_owner: felt):
    Ownable_only_owner()
    Ownable_owner.write(new_owner)
    return ()
end

# Possible addition would be revoke ownership