load ../src/bash_arg_parser

declare -gr new_command_usage_re="[^[:space:]]+ line [0-9]+: Usage is 'BAP_new_command <new_command>'$"
declare -gr set_top_level_cmd_name_usage_re="[^[:space:]]+ line [0-9]+: Usage is 'BAP_set_top_level_cmd_name <command> <top level cmd name>'"

pv() {
    for var_name; do
        echo "variable '$var_name' is '${!var_name}'"
    done
}

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
    run BAP_new_command "$var"
    pv output new_command_usage_re
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 3 ]
    [[ "${lines[0]}" =~ $new_command_usage_re ]]
    [ "${lines[1]}" = 'You must provide a valid bash variable name for parameter <new_command>' ]
    [ "${lines[2]}" = "Offending argument: '$var'" ]
}

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
