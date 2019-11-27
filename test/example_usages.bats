load ../src/bash_arg_parser
load utils

set -u

@test 'A simple command is created with no arguments and the parsing works correnctly' {
    local cmd=foo
    BAP_new_command "$cmd"
    BAP_generate_parse_func "$cmd"
    run parse_foo_args
    pv output

    [ "$status" -ne 0 ]
    [ "$output" = "Usage: $cmd" ]
}
