%builtins output range_check

from starkware.cairo.common.math import assert_nn_le, assert_nn
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.squash_dict import squash_dict
from starkware.cairo.common.alloc import alloc

struct KeyValue:
    member key: felt
    member value: felt
end

# O(n) on Cairo machine
func get_value_by_key_naive{ range_check_ptr }(
    list: KeyValue*, size, key) -> (value):

    let item = list

    if item.key == key:
        return (value=item.value)
    else:
        assert_nn(size - 1) # Checks if size != 0
    end

    return get_value_by_key_naive(
        list=list + KeyValue.SIZE,
        size=size - 1,
        key=key
    )
end

# O(1) on Cairo machine
func get_value_by_key{ range_check_ptr}(
    list: KeyValue*, size, key) -> (value):

    alloc_locals
    local idx
    %{
        # Fill idx with right key that corresponds to the value
        ENTRY_SIZE = ids.KeyValue.SIZE
        # These offsets return after how many fields each member start
        KEY_OFFSET = ids.KeyValue.key       # 0
        VALUE_OFFSET = ids.KeyValue.value   # 1

        # Iterate over address of list
        for i in range(ids.size):
            addr = ids.list.address_ + ENTRY_SIZE * i + KEY_OFFSET

            if memory[addr] == ids.key:
                ids.idx = i
                break
        else:
            raise Expection(f'Key {ids.key} was not found in the list')
    %}

    # Verify that we have the correct key
    let item : KeyValue = list[idx]
    # Or you can write item = [list + KeyValue.SIZE * idx]
    assert item.key = key

    # Verify that 0<=idx<=size-1
    assert_nn_le(a=idx, b=size-1)

    return (value=item.value)
end

func main{ output_ptr: felt* ,range_check_ptr}():
    alloc_locals

    local kvs: (KeyValue, KeyValue, KeyValue) = (
        KeyValue(key=2, value= 5),
        KeyValue(key=3, value= 6),
        KeyValue(key=4, value= 7),
    )
    let (local dict: DictAccess*) = alloc()

    let (__fp__, _) = get_fp_and_pc()


    let (value) = get_value_by_key(
        list=cast(&kvs, KeyValue*),
        size=3,
        key=3
    )

    serialize_word(value)
    return ()
end