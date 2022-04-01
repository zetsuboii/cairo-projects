%builtins range_check

func verify_less_than{ range_check_ptr }(value, up_bound) -> ():
    let range = range_check_ptr
    let range_check_ptr = range_check_ptr + 1
    assert [range] = up_bound - value 
    return ()
end

func verify_positive{ range_check_ptr }(value) -> ():
    let range = range_check_ptr
    let range_check_ptr = range_check_ptr + 1
    assert [range] = value 
    return ()
end

func main{ range_check_ptr }() -> ():
    verify_less_than{ range_check_ptr = range_check_ptr }(8, 5)
    return ()
end
