# A Library for Parsing Bash Arguments

[![Actions Status](https://github.com/pdietl/bash-arg-parse/workflows/CI/badge.svg)](https://github.com/pdietl/bash-arg-parse/actions)

BAP: Bash Arg Parse

Public API:

- `BAP_new_command(new_command)`
- `BAP_set_top_level_cmd_name(command, top_level_cmd_name)`
- `BAP_add_required_short_opt(command, opt_letter, opt_name, help_text)`
- `BAP_add_optional_short_opt(command, opt_letter, opt_name, help_text)`
- `BAP_set_opt_arg_type(command, opt_name, opt_arg_type)`
- `BAP_create_help_option(command)`
- `BAP_generate_parse_func(command)`

# Usage

The basic theory of operation is that one calls the various command to construct a command or subcommand to receive arguments. After this, one calls `BAP_generate_parse_func command_name`, which results in a new function coming into existence with the name `parse_new_command_args`. One then calls this function and captures the output. Calling `eval` on the captured output will result in local variables corresponding to the chosen optional and required arguments being set.

# Examples

## greet1
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
