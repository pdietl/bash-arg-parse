# A Library for Parsing Bash Arguments

[![Actions Status](https://github.com/pdietl/bash-arg-parse/workflows/CI/badge.svg)](https://github.com/pdietl/bash-arg-parse/actions)

BAP: Bash Arg Parse

Public API:

- `BAP_new_command(new_command)`
- `BAP_set_top_level_cmd_name(command, top_level_cmd_name)`
- `BAP_add_required_short_opt(command, opt_letter, opt_name [, help_text])`
- `BAP_add_optional_short_opt(command, opt_letter, opt_name [, help_text])`
- `BAP_set_opt_arg_type(command, opt_name, opt_arg_type)`
- `BAP_create_help_option(command)`
- `BAP_generate_parse_func(command)`

Some global variables are created for help text and opt help text:
- `$USAGE_TEXT_<command>`
- `$OPT_USAGE_TEXT_<command>`

# Usage

The basic theory of operation is that one calls the various command to construct a command or subcommand to receive arguments. After this, one calls `BAP_generate_parse_func command_name`, which results in a new function coming into existence with the name `parse_new_command_args`. One then calls this function and captures the output. Calling `eval` on the captured output will result in local variables corresponding to the chosen optional and required arguments being set.

# Restrictions on Public API Function Arguments
- `command` and `opt_name` must be valid Bash variable names
- `opt_arg_type` is only `existent_file` as of now. This creates a check that a provided argument is a file that exists

# Examples

## greet_req_arg
### Program Listing
```bash
#!/bin/bash

. ../src/bash_arg_parser

BAP_new_command 'greet'
BAP_add_required_short_opt 'greet' 'w' 'whom'
BAP_generate_parse_func 'greet'

greet() {
    local get_args
    get_args=$(parse_greet_args "$@") || exit
    eval "$get_args"
 
    echo "Hello, $whom!"
}

greet "$@"
```
### Example Program Interaction
```bash
$ ./greet1 
Usage: greet -w <whom>
$ ./greet1 -w
fatal: <whom> required.
Usage: greet -w <whom>
$ ./greet1 -w Pete
Hello, Pete!
```

## greet_opt_arg_and_help
### Program Listing
```bash
#!/bin/bash

. ../src/bash_arg_parser

BAP_new_command 'greet'
BAP_add_optional_short_opt 'greet' 'w' 'whom'
BAP_create_help_option 'greet'
BAP_generate_parse_func 'greet'

greet() {
    local get_args
    get_args=$(parse_greet_args "$@") || exit
    eval "$get_args"
 
    echo "Hello, ${whom:-you}!"
}

greet "$@"
```
### Example Program Interaction
```bash
$ ./greet_opt_arg_and_help 
Hello, you!
$ ./greet_opt_arg_and_help -h
Usage: greet -h [-w <whom>]
$ ./greet_opt_arg_and_help -h -w
Usage: greet -h [-w <whom>]
$ ./greet_opt_arg_and_help -w
fatal: <whom> required.
Usage: greet -h [-w <whom>]
$ ./greet_opt_arg_and_help -w 'Mr. Foo Bar'
Hello, Mr. Foo Bar!
```

## greet_sub_commands
### Program Listing
```bash
#!/bin/bash

set -u

. ../src/bash_arg_parser

BAP_new_command 'santa'
BAP_set_top_level_cmd_name 'santa' 'greet'
BAP_add_optional_short_opt 'santa' 'w' 'whom' 'The person whom santa should greet.'
BAP_create_help_option 'santa'
BAP_generate_parse_func 'santa'

BAP_new_command 'mom'
BAP_set_top_level_cmd_name 'mom' 'greet'
BAP_add_required_short_opt 'mom' 'w' 'whom'
BAP_create_help_option 'mom'
BAP_generate_parse_func 'mom'

declare -gr GLOBAL_USAGE_TEXT=$(cat <<EOM
Usage:
  greet $USAGE_TEXT_santa
  greet $USAGE_TEXT_mom

Options:$OPT_USAGE_TEXT_santa
EOM
)

mom() {
    local get_args
    get_args=$(parse_mom_args "$@") || exit
    eval "$get_args"
 
    echo "Mom loves you, ${whom}!"
    echo "Remaining arguments: $@"
}

santa() {
    local get_args
    get_args=$(parse_santa_args "$@") || exit
    eval "$get_args"
    
    if [ -z "$whom" ]; then
        echo "Santa is sad and alone since there is noohint: See the 'Note about fast-forwards' in 'git push --help' for details.
~/git/other/bash-arg-parse$ git rebase origin/master
First, rewinding head to replay your work on top of it...
Applying: updates
ne to greet. You are a monster."
    else
        echo "Santa put $whom on his naughty list!"
    fi

    echo "Remaining arguments: $@"
}

[ $# -eq 0 ] && echo "$GLOBAL_USAGE_TEXT" && exit 1

case "$1" in
    mom)
        shift
        mom "$@"
        ;;
    santa)
        shift
        santa "$@"
        ;;
    *)
        echo "$GLOBAL_USAGE_TEXT" && exit 1
        ;;
esac
```
### Example Program Interaction
```bash
$ ./greet_sub_commands 
Usage:
  greet santa -h [-w <whom>]
  greet mom -h -w <whom>

Options:
  -w      The person whom santa should greet.
$ ./greet_sub_commands  santa
Santa is sad and alone since there is noone to greet. You are a monster.
Remaining arguments: 
$ ./greet_sub_commands santa -w
fatal: <whom> required.
Usage: greet santa -h [-w <whom>]
$ ./greet_sub_commands santa -w 'you mom'
Santa put you mom on his naughty list!
Remaining arguments: 
$ ./greet_sub_commands santa -h
Usage: greet santa -h [-w <whom>]
$ ./greet_sub_commands santa -w 'you mama' foo bar
Santa put you mama on his naughty list!
Remaining arguments: foo bar
$ ./greet_sub_commands mom
Usage: greet mom -h -w <whom>
$ ./greet_sub_commands mom -h
Usage: greet mom -h -w <whom>
$ ./greet_sub_commands mom -w mom
Mom loves you, mom!
Remaining arguments: 
$ ./greet_sub_commands mom -w mom foo bar bax
Mom loves you, mom!
Remaining arguments: foo bar bax
$ ./greet_sub_commands mom -w 'Pete Pete'
Mom loves you, Pete Pete!
Remaining arguments: 
```
