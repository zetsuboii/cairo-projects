%builtins output range_check

from starkware.cairo.common.registers import get_fp_and_pc
# struct DictAccess
#   member key: felt
#   member prev_value: felt
#   member new_value: felt
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.squash_dict import squash_dict
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

struct Location:
    member row : felt
    member col : felt
end

func build_dict(loc_list: Location*, tile_list: felt*, n_steps, dict: DictAccess*) -> (dict: DictAccess*):
    if n_steps == 0:
        return (dict=dict)
    end

    assert dict.key = [tile_list]

    let next_loc: Location* = loc_list + Location.SIZE
    assert dict.prev_value = 4 * next_loc.row + next_loc.col

    assert dict.new_value = 4 * loc_list.row + loc_list.col

    return build_dict(
        loc_list=next_loc,
        tile_list=tile_list + 1,
        n_steps=n_steps - 1,
        dict=dict + DictAccess.SIZE
    )
end

func finalize_state(dict: DictAccess*, idx) -> (dict: DictAccess*):
    if idx == 0:
        return (dict=dict)
    end

    # dict[idx] = idx - 1
    assert dict.key = idx
    assert dict.prev_value = idx - 1
    assert dict.new_value = idx - 1
    
    return finalize_state(
        dict=dict + DictAccess.SIZE, 
        idx=idx-1
    )
end

func verify_valid_location(loc : Location*):
    # TODO: Learn about tempvar allocations
    # https://www.cairo-lang.org/docs/how_cairo_works/consts.html#tempvars
    tempvar row = loc.row
    # Assertion checks if row is either 0, 1, 2, or 3
    # row < 4 isn't used as it is an expensive op. on Cairo machine.
    assert row * (row - 1) * (row - 2) * (row - 3) = 0

    tempvar col = loc.col
    assert col * (col - 1) * (col - 2) * (col - 3) = 0

    # (?) Returns are necessary but you don't have to include them inside sigs.
    return ()
end

func verify_adjacent_locations(loc1 : Location*, loc2 : Location*):
    # This is needed if local variables are introduced
    # TODO: (?) Look into the way of doing this with pointers
    # https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html#registers
    # https://www.cairo-lang.org/docs/how_cairo_works/consts.html#local-vars
    alloc_locals
    local row_diff = loc1.row - loc2.row
    local col_diff = loc1.col - loc2.col

    # If locations have the same row check for columns.
    if row_diff == 0:
        # Assert col_diff is either 1 or -1
        assert col_diff * col_diff = 1
        return ()
    else:
        # Else check for rows
        assert row_diff * row_diff = 1
        assert col_diff = 0
        return ()
    end
end

func verify_location_list(loc_list : Location*, n_steps):
    verify_valid_location(loc=loc_list)

    if n_steps == 0:
        let loc = loc_list
        assert loc.col = 3
        assert loc.row = 3
        return ()
    end

    verify_adjacent_locations(loc1=loc_list, loc2=loc_list + Location.SIZE)

    verify_location_list(loc_list=loc_list + Location.SIZE, n_steps=n_steps - 1)
    return ()
end

func output_initial_values{ output_ptr: felt* }(squashed_dict:DictAccess*, n):
    if n == 0:
        return ()
    end

    serialize_word(squashed_dict.prev_value)
    
    return output_initial_values(
        squashed_dict=squashed_dict + DictAccess.SIZE,
        n=n - 1
    )
end

func check_solution{ output_ptr: felt*, range_check_ptr }(
    loc_list: Location*, 
    tile_list: felt*, 
    n_steps
):
    alloc_locals

    verify_location_list(loc_list=loc_list, n_steps=n_steps)

    # We'll start by allocating memory for both DictAccess lists
    let (local dict_start: DictAccess*) = alloc()
    let (local squashed_dict: DictAccess*) = alloc()

    let (dict_end) = build_dict(
        loc_list=loc_list,
        tile_list=tile_list,
        n_steps=n_steps,
        dict=dict_start
    )

    let (dict_end) = finalize_state(dict=dict_end, idx=15)

    let (squashed_dict_end: DictAccess*) = squash_dict(
        dict_accesses=dict_start,
        dict_accesses_end=dict_end,
        squashed_dict=squashed_dict
    )

    # output_initial_values will revoke the pointer to range check
    # One solution is to store the pointer locally as local variables
    # don't get revoked
    # (?) https://www.cairo-lang.org/docs/how_cairo_works/consts.html#revoked-references
    local range_check_ptr = range_check_ptr

    # Checks if squashed_dict has 15 elements
    assert squashed_dict_end - squashed_dict = 15 * DictAccess.SIZE

    output_initial_values(squashed_dict=squashed_dict, n=15)

    serialize_word(4 * loc_list.row * loc_list.col)
    serialize_word(n_steps)

    return ()
end

# Hard-coded solution
# func main{ output_ptr: felt*, range_check_ptr }():
#     alloc_locals

#     local loc_tuple: (Location, Location, Location, Location, Location) = (
#         Location(row=0, col=2),
#         Location(row=1, col=2),
#         Location(row=1, col=3),
#         Location(row=2, col=3),
#         Location(row=3, col=3)
#     )

#     local tiles: (felt, felt, felt, felt) = (3, 7, 8, 12)

#     # TODO: Elaborate
#     # Whenever location of a variable is needed, this must be called
#     # in order to get a frame pointer which will help with referencing
#     let (__fp__, _) = get_fp_and_pc()

#     check_solution(
#         loc_list=cast(&loc_tuple, Location*),
#         tile_list=cast(&tiles, felt*),
#         n_steps=4
#     )
#     return ()
# end

# Prover-verifier method (the right usage)
func main{ output_ptr: felt*, range_check_ptr }():
    alloc_locals

    local loc_list: Location*
    local tile_list: felt*
    local n_steps

    %{
        # (?) This is Python code

        # Use 'program_input' to access prover inputs
        locations = program_input['loc_list']
        tiles = program_input['tile_list']

        # Use 'ids' to access the local variables
        ids.loc_list = loc_list = segments.add()
        for i, val in enumerate(locations):
            memory[loc_list + i] = val

        ids.tile_list = tile_list = segments.add()
        for i, val in enumerate(tiles):
            memory[tile_list + i] = val

        ids.n_steps = len(tiles)

        # Sanity check that only runs on prover side
        assert len(locations) == 2 * (len(tiles) + 1)
    %}

    check_solution(
        loc_list=loc_list,
        tile_list=tile_list,
        n_steps=n_steps
    )
    return ()
end