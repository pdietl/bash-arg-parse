load ../src/bash_arg_parser
load utils

declare -gr new_command_usage_re="[^[:space:]]+ line 52: Usage is 'BAP_new_command <new_command>'$"
declare -gr set_top_level_cmd_name_usage_re="[^[:space:]]+ line 52: Usage is 'BAP_set_top_level_cmd_name <command> <top level cmd name>'$"
declare -gr add_required_short_opt_re="[^[:space:]]+ line 52: Usage is 'BAP_add_required_short_opt <command> <opt_letter> <opt_name>'$"
declare -gr add_optional_short_opt_re="[^[:space:]]+ line 52: Usage is 'BAP_add_optional_short_opt <command> <opt_letter> <opt_name>'$"
declare -gr generate_parse_func_re="[^[:space:]]+ line 52: Usage is 'BAP_generate_parse_func <command>'$"

#####################
# BAP_new_command() #
#####################

@test 'BAP_new_command() succeeds when run with valid argument' {
    run BAP_new_command 'example'
    pv output
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test 'BAP_new_command() fails when run without an argument' {
    run BAP_new_command
    pv output new_command_usage_re
    
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $new_command_usage_re ]]
}

@test 'BAP_new_command() fails when run with an argument which is not a valid Bash variable name' {
    local var='I am not a valid Bash variable name'
    local re=".*: line 52: 'You must provide a valid Bash variable name for parameter <new_command>'"
    run BAP_new_command "$var"
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [[ "${lines[0]}" =~ re ]]
    [ "${lines[1]}" = "Offending argument: '$var'" ]
}

################################
# BAP_set_top_level_cmd_name() #
################################

@test 'BAP_set_top_level_cmd_name() succeeds when run with a valid argument' {
    local cmd=foo
    BAP_new_command "$cmd"
    run BAP_set_top_level_cmd_name "$cmd" 'bar'
    pv output
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test 'BAP_set_top_level_cmd_name() fails when BAP_new_command has not been called already' {
    local cmd=foo
    local re=".* \(BAP_set_top_level_cmd_name\) must call 'BAP_new_command\(\)' first to define command '$cmd'$"
    run BAP_set_top_level_cmd_name "$cmd" 'bar'
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_set_top_level_cmd_name() fails when called with no arguments' {
    run BAP_set_top_level_cmd_name
    pv output set_top_level_cmd_name_usage_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $set_top_level_cmd_name_usage_re ]]
}

@test 'BAP_set_top_level_cmd_name() fails when called with only one argument' {
    run BAP_set_top_level_cmd_name 'foo'
    pv output set_top_level_cmd_name_usage_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $set_top_level_cmd_name_usage_re ]]
}

################################
# BAP_add_required_short_opt() #
################################

@test 'BAP_add_required_short_opt() fails when called with no arguments' {
    run BAP_add_required_short_opt
    pv output add_required_short_opt_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $add_required_short_opt_re ]]
}

@test 'BAP_add_required_short_opt() fails when called with only one argument' {
    run BAP_add_required_short_opt 'foo'
    pv output add_required_short_opt_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $add_required_short_opt_re ]]
}

@test 'BAP_add_required_short_opt() fails when called with only two arguments' {
    run BAP_add_required_short_opt 'foo' 'bar'
    pv output add_required_short_opt_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $add_required_short_opt_re ]]
}

@test 'BAP_add_required_short_opt() fails when BAP_new_command has not been called already' {
    local cmd=foo
    local re=".* \(BAP_add_required_short_opt\) must call 'BAP_new_command\(\)' first to define command '$cmd'$"
    run BAP_set_top_level_cmd_name "$cmd" 'bar'
    pv output re
    run BAP_add_required_short_opt "$cmd" 'bar' 'baz'
    pv output add_required_short_opt_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_add_required_short_opt() fails when given an argument for <opt_letter> which is not only one character' {
    local cmd=foo
    local short_opt_letter=bar
    local re='.*: line 52: \(BAP_add_required_short_opt\) must only provide a single letter for the short opt letter argument!'$'\n'"Offending argument: '$short_opt_letter'"
    BAP_new_command "$cmd"
    run BAP_add_required_short_opt "$cmd" "$short_opt_letter" 'baz'
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_add_required_short_opt() fails when given an argument for <opt_name> which is not a valid Bash variable name' {
    local cmd=foo
    local not_a_bash_var_name='bar baz'
    local re='.*: line 52: \(BAP_add_required_short_opt\) must provide a valid Bash variable name for parameter <opt_name>'$'\n'"Offending argument: '$not_a_bash_var_name'"
    BAP_new_command "$cmd"
    run BAP_add_required_short_opt "$cmd" q "$not_a_bash_var_name"
    pv output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_add_required_short_opt() succeeds when called with valid arguments without optional help text' {
    local cmd=foo
    BAP_new_command "$cmd"
    run BAP_add_required_short_opt "$cmd" b baz
    pv output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 0 ]
}

################################
# BAP_add_optional_short_opt() #
################################

@test 'BAP_add_optional_short_opt() fails when called with no arguments' {
    run BAP_add_optional_short_opt
    pv output add_optional_short_opt_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $add_optional_short_opt_re ]]
}

@test 'BAP_add_optional_short_opt() fails when called with only one argument' {
    run BAP_add_optional_short_opt 'foo'
    pv output add_optional_short_opt_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $add_optional_short_opt_re ]]
}

@test 'BAP_add_optional_short_opt() fails when called with only two arguments' {
    run BAP_add_optional_short_opt 'foo' 'bar'
    pv output add_optional_short_opt_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $add_optional_short_opt_re ]]
}

@test 'BAP_add_optional_short_opt() fails when BAP_new_command has not been called already' {
    local cmd=foo
    local re=".* \(BAP_add_optional_short_opt\) must call 'BAP_new_command\(\)' first to define command '$cmd'$"
    run BAP_add_optional_short_opt "$cmd" 'bar' 'baz'
    pv output add_optional_short_opt_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_add_optional_short_opt() fails when given an argument for <opt_letter> which is not only one character' {
    local cmd=foo
    local short_opt_letter=bar
    local re='.*: line 52: \(BAP_add_optional_short_opt\) must only provide a single letter for the short opt letter argument!'$'\n'"Offending argument: '$short_opt_letter'"
    BAP_new_command "$cmd"
    run BAP_add_optional_short_opt "$cmd" "$short_opt_letter" 'baz'
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_add_optional_short_opt() fails when given an argument for <opt_name> which is not a valid Bash variable name' {
    local cmd=foo
    local not_a_bash_var_name='bar baz'
    local re='.*: line 52: \(BAP_add_optional_short_opt\) must provide a valid Bash variable name for parameter <opt_name>'$'\n'"Offending argument: '$not_a_bash_var_name'"
    BAP_new_command "$cmd"
    run BAP_add_optional_short_opt "$cmd" q "$not_a_bash_var_name"
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_add_optional_short_opt() succeeds when called with valid arguments without optional help text' {
    local cmd=foo
    BAP_new_command "$cmd"
    run BAP_add_optional_short_opt "$cmd" b baz
    pv output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 0 ]
}

#############################
# BAP_generate_parse_func() #
#############################

@test 'BAP_generate_parse_func fails when called with no arguments' {
    run BAP_generate_parse_func
    pv output generate_parse_func_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $generate_parse_func_re ]]
}

@test 'BAP_generate_parse_func fails when BAP_new_command has not been called already' {
    local cmd=foo
    local re="^.* \(BAP_generate_parse_func\) must call 'BAP_new_command\(\)' first to define command '$cmd'\$"
    run BAP_generate_parse_func "$cmd"
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_generate_parse_func succeeds when called with valid arguments' {
    local cmd=foo
    BAP_new_command "$cmd"
    run BAP_generate_parse_func "$cmd"
    pv output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 0 ]
}

@test 'BAP_generate_parse_func when called correctly generates a properly named parser function' {
    local cmd=foo
    BAP_new_command "$cmd"
    BAP_generate_parse_func "$cmd"
    type -t "parse_${cmd}_args"
}

########################
# BAP_set_opt_arg_type #
########################

@test 'BAP_set_opt_arg_type fails when called with no arguments' {
    local re="^.*: line 52: Usage is 'BAP_set_opt_arg_type <command> <opt_name> <opt_arg_type>'$"
    run BAP_set_opt_arg_type
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_set_opt_arg_type fails when BAP_new_command has not been called already' {
    local cmd=foo
    local re="^.* must call 'BAP_new_command\(\)' first to define command '$cmd'$"
    run BAP_set_opt_arg_type "$cmd" 'bar' 'baz'
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_set_opt_arg_type fails when BAP_add_optional_short_opt or BAP_add_required_short_opt() has not been called already' {
    local cmd=foo
    local opt=bar
    local re="^.* must call 'BAP_add_optional_short_opt\(\)' or 'BAP_add_required_short_opt\(\)' to define option '$opt'$"
    BAP_new_command "$cmd"
    run BAP_set_opt_arg_type "$cmd" "$opt" 'baz'
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_set_opt_arg_type succeeds when called with valid arguments' {
    local cmd=foo
    local opt=bar
    BAP_new_command "$cmd"
    BAP_add_optional_short_opt "$cmd" 'b' "$opt"
    run BAP_set_opt_arg_type "$cmd" "$opt" existent_file
    pv output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 0 ]
}

@test 'BAP_set_opt_arg_type fails when called with an invalid opt type' {
    local cmd=foo
    local opt=bar
    local re=".* opt arg type must be one of: \[existent_file\]$"
    BAP_new_command "$cmd"
    BAP_add_optional_short_opt "$cmd" 'b' "$opt"
    run BAP_set_opt_arg_type "$cmd" "$opt" garbage
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

#####################################
# BAP_generate_top_level_cmd_parser #
#####################################

@test 'BAP_generate_top_level_cmd_parser fails when called with no arguments' {
    local re="^.*: line 52: Usage is 'BAP_generate_top_level_cmd_parser <top_level_cmd_name>'$"
    run BAP_generate_top_level_cmd_parser
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_generate_top_level_cmd_parser fails when called with an argument of a top-level command which has not yet been created with a call to BAP_set_top_level_cmd_name()' {
    local top_level_cmd=foo
    local re="^.*: line 52: \(BAP_generate_top_level_cmd_parser\) must call 'BAP_set_top_level_cmd_name\(\)' with a second argument of '$top_level_cmd' first!$"
    run BAP_generate_top_level_cmd_parser "$top_level_cmd"
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]

}

@test 'BAP_generate_top_level_cmd_parser fails when called with a top-level command associated with a sub command which has not yet had BAP_generate_parse_func called on it' {
    local cmd=bar
    local top_level_cmd=foo
    local re="^.*: line 52: \(BAP_generate_top_level_cmd_parser\) must call 'BAP_generate_parse_func\(\)' with an argument of 'bar' first!$"

    BAP_new_command "$cmd"
    BAP_set_top_level_cmd_name "$cmd" "$top_level_cmd"
    run BAP_generate_top_level_cmd_parser "$top_level_cmd"
    pv output re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [[ "$output" =~ $re ]]
}

@test 'BAP_generate_top_level_cmd_parser succeeds when called with valid arguments and with the proper funtions having been previously called' {
    local cmd=bar
    local top_level_cmd=foo

    BAP_new_command "$cmd"
    BAP_set_top_level_cmd_name "$cmd" "$top_level_cmd"
    BAP_generate_parse_func "$cmd"
    eval "$cmd() { :; }"
    run BAP_generate_top_level_cmd_parser "$top_level_cmd"
    pv output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 0 ]
}
