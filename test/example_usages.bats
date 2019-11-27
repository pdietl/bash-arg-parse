load ../src/bash_arg_parser
load utils

set -u

@test 'A command is created with no arguments and the parsing works correctly' {
    local cmd=foo
    BAP_new_command "$cmd"
    BAP_generate_parse_func "$cmd"
    run parse_${cmd}_args
    pv output

    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 0 ]
}

@test 'A command is created with no arguments and help text, parsing works correctly and help is displayed' {
    local cmd=foo
    BAP_new_command "$cmd"
    BAP_create_help_option "$cmd"
    BAP_generate_parse_func "$cmd"
    
    run parse_${cmd}_args
    pv output cmd
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 0 ]
    
    run parse_foo_args -h
    pv output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "Usage: $cmd -h" ]
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
    local func_arg=dir_foo
    BAP_new_command "$cmd"
    BAP_add_required_short_opt "$cmd" "$opt_letter" "$opt_name"
    BAP_generate_parse_func "$cmd"
    
    run parse_${cmd}_args -o "$func_arg"
    pv output cmd opt_letter opt_name func_arg
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "local output_dir=$func_arg; " ]
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
    [ "$output" = "local output_dir=$func_arg; " ]
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
    [ "$output" = "local output_dir=; " ]
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
