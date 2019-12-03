load ../src/bash_arg_parser
load utils

set -u

@test 'A command is created with no arguments and the parsing works correctly' {
    local cmd=foo
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args" > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = 'shift 0; ' ]
}

@test 'A command is created with one required argument and fails with proper usage text when that argument is not given' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    BAP_new_command "$cmd"
    BAP_add_required_short_opt "$cmd" "$opt_letter" "$opt_name"
    BAP_generate_parse_func "$cmd"
    
    run parse_${cmd}_args
    pv output cmd opt_letter opt_name
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "Usage: $cmd -$opt_letter <$opt_name>" ]
}
@test 'A command is created with one required argument and fails with proper usage text when the corresponding option flag is provided as an argument, but there is no argument after the flag' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    BAP_new_command "$cmd"
    BAP_add_required_short_opt "$cmd" "$opt_letter" "$opt_name"
    BAP_generate_parse_func "$cmd"
    
    run parse_${cmd}_args -o
    pv output cmd opt_letter opt_name
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "fatal: <$opt_name> required." ]
    [ "${lines[1]}" = "Usage: $cmd -$opt_letter <$opt_name>" ]
}

@test 'A command is created with one required argument and succeeds when that argument is given' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    local func_arg='dir foo'
    BAP_new_command "$cmd"
    BAP_add_required_short_opt "$cmd" "$opt_letter" "$opt_name"
    BAP_generate_parse_func "$cmd"
    
    run parse_${cmd}_args -o "$func_arg"
    pv output cmd opt_letter opt_name func_arg
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "local output_dir='$func_arg'; shift 2; " ]
}

@test 'A command is created with one optional argument and succeeds when that argument is given' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    local func_arg=dir_foo
    BAP_new_command "$cmd"
    BAP_add_optional_short_opt "$cmd" "$opt_letter" "$opt_name"
    BAP_generate_parse_func "$cmd"
    
    run parse_${cmd}_args -o "$func_arg"
    pv output cmd opt_letter opt_name func_arg
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "local output_dir='$func_arg'; shift 2; " ]
}

@test 'A command is created with one optional argument and succeeds when that argument is not given' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    BAP_new_command "$cmd"
    BAP_add_optional_short_opt "$cmd" "$opt_letter" "$opt_name"
    BAP_generate_parse_func "$cmd"
    
    run parse_${cmd}_args
    pv output cmd opt_letter opt_name
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "local output_dir=''; shift 0; " ]
}

@test 'A command is created with one optional argument and fails with proper usage text when the corresponding option flag is provided as an argument, but there is no argument after the flag' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    BAP_new_command "$cmd"
    BAP_add_optional_short_opt "$cmd" "$opt_letter" "$opt_name"
    BAP_generate_parse_func "$cmd"
    
    run parse_${cmd}_args -o
    pv output cmd opt_letter opt_name
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "fatal: <$opt_name> required." ]
    [ "${lines[1]}" = "Usage: $cmd [-$opt_letter <$opt_name>]" ]
}
