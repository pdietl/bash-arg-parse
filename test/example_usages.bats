load ../src/bash_arg_parser
load utils

set -u

@test 'A command is created with no arguments and the parsing works correctly' {
    local cmd=foo
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv cmd output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = 'shift 0; ' ]
}

@test 'A command is created with one required argument and fails with proper usage text when that argument is not given' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"
    
    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "Usage: $cmd -$opt_letter <$opt_name>" ]
}

@test 'A command is created with one required argument and fails with proper usage text when the corresponding option flag is provided as an argument, but there is no argument after the flag' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out" -o
    
    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "fatal: <$opt_name> required." ]
    [ "${lines[1]}" = "Usage: $cmd -$opt_letter <$opt_name>" ]
}

@test 'A command is created with one required argument and succeeds when that argument is given' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    local func_arg=i_am_a_directory
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out" -"$opt_letter" "$func_arg"
    
    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name func_arg output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "local output_dir='$func_arg'; shift 2; " ]
}

@test 'A command is created with one optional argument and succeeds when that argument is given' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    local func_arg=dir_foo
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_optional_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out" -"$opt_letter" "$func_arg"

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name func_arg output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "local output_dir='$func_arg'; shift 2; " ]
}

@test 'A command is created with one optional argument and succeeds when that argument is not given' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    local func_arg=dir_foo
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_optional_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name func_arg output
    [ "$status" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "local output_dir=''; shift 0; " ]
}

@test 'A command is created with one optional argument and fails with proper usage text when the corresponding option flag is provided as an argument, but there is no argument after the flag' {
    local cmd=foo
    local opt_letter=o
    local opt_name=output_dir
    local func_arg=dir_foo
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_optional_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out" -"$opt_letter"

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name func_arg output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "fatal: <$opt_name> required." ]
    [ "${lines[1]}" = "Usage: $cmd [-$opt_letter <$opt_name>]" ]
}

@test 'A command is created with no help text and the usage does not contain a [-h] option' {
    local cmd=foo
    local opt_letter=b
    local opt_name=bar
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "Usage: $cmd -$opt_letter <$opt_name>" ]
}

@test 'A command is created with help text for an option and the usage does contain a [-h] option' {
    local cmd=foo
    local opt_letter=b
    local opt_name=bar
    local help_text="I am the $opt_name help text."
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_add_short_opt_help_text '$opt_letter' '$help_text'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name help_text output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "Usage: $cmd [-h] -$opt_letter <$opt_name>" ]
}

@test 'A command is created with help text for an option and running the command with -h shows the opt help text' {
    local cmd=foo
    local opt_letter=b
    local opt_name=bar
    local help_text="I am the $opt_name help text."
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_add_short_opt_help_text '$opt_letter' '$help_text'
        BAP_generate_parse_func '$cmd'
        parse_${cmd}_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out" -h

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name help_text output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" = "Usage: $cmd [-h] -$opt_letter <$opt_name>" ]
    [ "${lines[1]}" = "Options:" ]
    [ "${lines[2]}" = "  -$opt_letter    $help_text" ]
}

@test 'Two commands are created with help text for a common option and running each command with -h shows the opt help text' {
    local cmd1=foo
    local cmd2=baz
    local opt_letter=b
    local opt_name=bar
    local help_text="I am the $opt_name help text."
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd1'
        BAP_add_required_short_opt '$cmd1' '$opt_letter' '$opt_name'
        
        BAP_new_command '$cmd2'
        BAP_add_required_short_opt '$cmd2' '$opt_letter' '$opt_name'
        
        BAP_add_short_opt_help_text '$opt_letter' '$help_text'

        BAP_generate_parse_func '$cmd1'
        BAP_generate_parse_func '$cmd2'

        case \$1 in
            $cmd1) shift; parse_${cmd1}_args \"\$@\" ;;
            $cmd2) shift; parse_${cmd2}_args \"\$@\" ;;
        esac
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out" "$cmd1" -h

    cat "$temp"
    cat "$temp.out"
    pv cmd1 cmd2 opt_letter opt_name help_text output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" = "Usage: $cmd1 [-h] -$opt_letter <$opt_name>" ]
    [ "${lines[1]}" = "Options:" ]
    [ "${lines[2]}" = "  -$opt_letter    $help_text" ]
    
    run bash "$temp.out" "$cmd2" -h

    pv cmd1 cmd2 opt_letter opt_name help_text output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" = "Usage: $cmd2 [-h] -$opt_letter <$opt_name>" ]
    [ "${lines[1]}" = "Options:" ]
    [ "${lines[2]}" = "  -$opt_letter    $help_text" ]
}

@test 'A top-level parser is generated for a single sub command and the output text looks correct' {
    local cmd=foo
    local opt_letter=b
    local opt_name=bar
    local top_level_cmd=top-level
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_set_top_level_cmd_name '$cmd' '$top_level_cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'

        BAP_generate_top_level_cmd_parser '$top_level_cmd'

        parse_top_level_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name top_level_cmd output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "Usage:" ]
    [ "${lines[1]}" = "  $top_level_cmd $cmd -$opt_letter <$opt_name>" ]
}

@test 'A top-level parser is generated for a two sub commands and the output text looks correct' {
    local cmd=foo
    local cmd2=baz
    local opt_letter=b
    local opt_name=bar
    local top_level_cmd=top-level
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_set_top_level_cmd_name '$cmd' '$top_level_cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_generate_parse_func '$cmd'
        
        BAP_new_command '$cmd2'
        BAP_set_top_level_cmd_name '$cmd2' '$top_level_cmd'
        BAP_generate_parse_func '$cmd2'

        BAP_generate_top_level_cmd_parser '$top_level_cmd'

        parse_top_level_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name top_level_cmd output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" = "Usage:" ]
    [ "${lines[1]}" = "  $top_level_cmd $cmd -$opt_letter <$opt_name>" ]
    [ "${lines[2]}" = "  $top_level_cmd $cmd2" ]
}

@test 'A top-level parser is generated for a single sub command which has help text and the output text looks correct' {
    local cmd=foo
    local opt_letter=b
    local opt_name=bar
    local help_text="I am the help text for option $opt_name"
    local top_level_cmd=top-level
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_set_top_level_cmd_name '$cmd' '$top_level_cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_add_short_opt_help_text '$opt_letter' '$help_text'
        BAP_generate_parse_func '$cmd'

        BAP_generate_top_level_cmd_parser '$top_level_cmd'

        $cmd() {
            parse_${cmd}_args \"\$@\" || exit 1
        }

        parse_top_level_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv cmd opt_letter opt_name top_level_cmd output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 6 ]
    [ "${lines[0]}" = "Usage:" ]
    [ "${lines[1]}" = "  $top_level_cmd [-h]" ]
    [ "${lines[2]}" = "  $top_level_cmd $cmd [-h] -$opt_letter <$opt_name>" ]
    [ "${lines[3]}" = "Options:" ]
    [ "${lines[4]}" = "  -h    Show this help text." ]
    [ "${lines[5]}" = "  -$opt_letter    $help_text" ]

    run bash "$temp.out" "$cmd"
    pv output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "Usage: $top_level_cmd $cmd [-h] -$opt_letter <$opt_name>" ]
    
    run bash "$temp.out" "$cmd" -h
    pv output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" = "Usage: $top_level_cmd $cmd [-h] -$opt_letter <$opt_name>" ]
    [ "${lines[1]}" = "Options:" ]
    [ "${lines[2]}" = "  -$opt_letter    $help_text" ]
}

@test 'A top-level parser is generated for two sub commands which both have help text and the output text looks correct -- which is to say that the top-level command options list contains the union of all the options of the sub commands' {
    local cmd=foo
    local cmd1=baz
    local opt_letter=b
    local opt_letter1=q
    local opt_name=bar
    local opt_name1=qux
    local help_text="I am the help text for option $opt_name"
    local help_text1="I am the help text for option $opt_name1"
    local top_level_cmd=top-level
    local temp
    temp=$(mktemp)
    echo "
        BAP_new_command '$cmd'
        BAP_set_top_level_cmd_name '$cmd' '$top_level_cmd'
        BAP_add_required_short_opt '$cmd' '$opt_letter' '$opt_name'
        BAP_add_short_opt_help_text '$opt_letter' '$help_text'
        BAP_generate_parse_func '$cmd'
        
        BAP_new_command '$cmd1'
        BAP_set_top_level_cmd_name '$cmd1' '$top_level_cmd'
        BAP_add_required_short_opt '$cmd1' '$opt_letter1' '$opt_name1'
        BAP_add_short_opt_help_text '$opt_letter1' '$help_text1'
        BAP_generate_parse_func '$cmd1'

        BAP_generate_top_level_cmd_parser '$top_level_cmd'

        $cmd() {
            parse_${cmd}_args \"\$@\" || exit 1
        }

        parse_top_level_args \"\$@\"
        " > "$temp"
    src/bash_arg_parser "$temp"
    run bash "$temp.out"

    cat "$temp"
    cat "$temp.out"
    pv cmd cmd1 opt_letter opt_letter1 opt_name opt_name1 top_level_cmd output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 8 ]
    [ "${lines[0]}" = "Usage:" ]
    [ "${lines[1]}" = "  $top_level_cmd [-h]" ]
    [ "${lines[2]}" = "  $top_level_cmd $cmd [-h] -$opt_letter <$opt_name>" ]
    [ "${lines[3]}" = "  $top_level_cmd $cmd1 [-h] -$opt_letter1 <$opt_name1>" ]
    [ "${lines[4]}" = "Options:" ]
    [ "${lines[5]}" = "  -h    Show this help text." ]
    [ "${lines[6]}" = "  -$opt_letter    $help_text" ]
    [ "${lines[7]}" = "  -$opt_letter1    $help_text1" ]

    run bash "$temp.out" "$cmd"
    pv output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "$output" = "Usage: $top_level_cmd $cmd [-h] -$opt_letter <$opt_name>" ]
    
    run bash "$temp.out" "$cmd" -h
    pv output
    [ "$status" -ne 0 ]
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" = "Usage: $top_level_cmd $cmd [-h] -$opt_letter <$opt_name>" ]
    [ "${lines[1]}" = "Options:" ]
    [ "${lines[2]}" = "  -$opt_letter    $help_text" ]
}
