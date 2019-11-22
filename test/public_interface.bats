load ../src/bash_arg_parser

@test ''BAP_new_command' succeeds when run with valid argument' {
    run BAP_new_command 'example'
    echo "$output"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test ''BAP_new_command' fails when run without an argument' {
    local re=".*Usage is 'BAP_new_command <new_command>'$"
    run BAP_new_command
    echo "$output"
    [ "$status" -ne 0 ]
    [[ "$output" =~ $re ]]
}
