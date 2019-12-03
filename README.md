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
- `BAP_generate_top_level_cmd_parser(top_level_cmd_name)`

Some global variables are created for help text and opt help text:
- `$USAGE_TEXT_<command>`
- `$OPT_USAGE_TEXT_<command>`

# Usage

The basic theory of operation is that one calls the various command to construct a command or subcommand to receive arguments. After this, one calls `BAP_generate_parse_func command_name`, which results in a new function coming into existence with the name `parse_new_command_args`. One then calls this function and captures the output. Calling `eval` on the captured output will result in local variables corresponding to the chosen optional and required arguments being set.

# Two Ways of Usage: As a Aourced Library or as a Generator/Preprocessor
You can either include the bash parsing library via a source command into your source code, or you can call the bash parsing library with your source code as the argument. In the latter case, you if you call the library with the argument 'foo' then the output file will be called 'foo.out' and it shall be a standalone version of script 'foo' with all of the parsing functions included within it. A caveat, if you use the latter medthod, then you may __*ONLY*__ use string literals as your argumnets to the various `BAP_` functions.

# Restrictions on Public API Function Arguments
- `command` and `opt_name` must be valid Bash variable names
- `opt_arg_type` is only `existent_file` as of now. This creates a check that a provided argument is a file that exists

# Function Docs
- `BAP_new_command(new_command)`: must be the first in a series of calls to the other functions. This function sets up various internal data structures.

- `BAP_set_top_level_cmd_name(command, top_level_cmd_name)`: Adds a top-level name to a command. For instance, if you make sub commands `foo`, `bar`, and `baz` and you want them all to be sub commands of `qux`, you would use this function. The result will be usage text which prefixes the top-level command to the sub commands. like so: `Usage: qux foo`.

- `BAP_add_required_short_opt(command, opt_letter, opt_name [, help_text])`: This function adds a new non-optional short option to a given command. The `opt_letter` is the letter of the short option and the `opt_name` is the text that will describe the argument of the short option. Exmaple: given a command foo where you want to add a short option of `-c <config>`: `BAP_add_required_short_opt foo c config`. Additionally, one may provide an optional help text to further describe what is expected of the option argument. This will be generated in the global variable `OPT_USAGE_TEXT_<command>`.

- `BAP_add_optional_short_opt(command, opt_letter, opt_name [, help_text])`: Same usage as `BAP_add_required_short_opt(command, opt_letter, opt_name [, help_text])`, but the option is not required.

- `BAP_set_opt_arg_type(command, opt_name, opt_arg_type)`: This function is used to enforce restrictions upon option arguments. The only type option currently is `existent_file`, which requires that the option argument provided is a file which exists.

- `BAP_create_help_option(command)`: This function adds a `-h` option to the givne command which will display the usage text. This function is also required to be called in order for any option help text to be displayed.

- `BAP_generate_parse_func(command)`: When one is all done setting up parameters for a command, one should call this function to generate a new function which will parse the arguments. Given an argument of `foo` for parameter `command`, a function named `parse_foo_args` will be produced. This new function will return a string which when `eval-ed` will insert local varaibles corrsponding to option names into the current function.

- `BAP_generate_top_level_cmd_parser(top_level_cmd_name)`: This command will automatically generate a parser which will delegate to sub parser handling functions for each sub command. See examples.


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


## greet_sub_commands_generate_top_level_parser
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

BAP_generate_top_level_cmd_parser 'greet'

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
        echo "Santa is sad and alone since there is noone to greet. You are a monster."
    else
        echo "Santa put $whom on his naughty list!"
    fi

    echo "Remaining arguments: $@"
}

parse_top_level_args "$@"
```

### Example Program Interaction
```bash
$ ./greet_sub_commands_generate_top_level_parser 
Usage:
  greet santa -h [-w <whom>]
  greet mom -h -w <whom>

Options:
  -w      The person whom santa should greet.

$ ./greet_sub_commands_generate_top_level_parser  santa
Santa is sad and alone since there is noone to greet. You are a monster.
Remaining arguments: 
$ ./greet_sub_commands_generate_top_level_parser santa
Santa is sad and alone since there is noone to greet. You are a monster.
Remaining arguments: 
$ ./greet_sub_commands_generate_top_level_parser santa =h
Santa is sad and alone since there is noone to greet. You are a monster.
Remaining arguments: =h
$ ./greet_sub_commands_generate_top_level_parser santa -h
Usage: greet santa -h [-w <whom>]
$ ./greet_sub_commands_generate_top_level_parser santa -w 
fatal: <whom> required.
Usage: greet santa -h [-w <whom>]
$ ./greet_sub_commands_generate_top_level_parser santa -w you
Santa put you on his naughty list!
Remaining arguments: 
$ ./greet_sub_commands_generate_top_level_parser santa -w you bar
Santa put you on his naughty list!
Remaining arguments: bar
$ ./greet_sub_commands_generate_top_level_parser santa
Santa is sad and alone since there is noone to greet. You are a monster.
Remaining arguments: 
$ ./greet_sub_commands_generate_top_level_parser 
Usage:
  greet santa -h [-w <whom>]
  greet mom -h -w <whom>

Options:
  -w      The person whom santa should greet.

$ ./greet_sub_commands_generate_top_level_parser mom
Usage: greet mom -h -w <whom>
$ ./greet_sub_commands_generate_top_level_parser mom -h
Usage: greet mom -h -w <whom>
$ ./greet_sub_commands_generate_top_level_parser mom -w 'Pete'
Mom loves you, Pete!
Remaining arguments: 
$ ./greet_sub_commands_generate_top_level_parser mom -w 'Pete' other
Mom loves you, Pete!
Remaining arguments: other
```
