# A Library for Parsing Bash Arguments

[![Actions Status](https://github.com/pdietl/bash-arg-parse/workflows/CI/badge.svg)](https://github.com/pdietl/bash-arg-parse/actions)

BAP: Bash Arg Parse

Public API:

- `BAP_new_command(new_command)`
- `BAP_set_top_level_cmd_name(command, top_level_cmd_name)`
- `BAP_add_required_short_opt(command, opt_letter, opt_name)`
- `BAP_add_optional_short_opt(command, opt_letter, opt_name)`
- `BAP_set_opt_arg_type(command, opt_name, opt_arg_type)`
- `BAP_add_short_opt_help_text(opt_letter, help_text)`
- `BAP_generate_parse_func(command)`
- `BAP_generate_top_level_cmd_parser(top_level_cmd_name)`

Some global variables are created for help text and opt help text:
- `$USAGE_TEXT_<command>`
- `$OPT_USAGE_TEXT_<command>`

# Usage

The basic theory of operation is that one calls the various command to construct a command or subcommand to receive arguments. After this, one calls `BAP_generate_parse_func command_name`, which results in a new function coming into existence with the name `parse_new_command_args`. One then calls this function and captures the output. Calling `eval` on the captured output will result in local variables corresponding to the chosen optional and required arguments being set.

# Two Ways of Usage: As A Sourced Library or As A Generator/Preprocessor
You can either include the bash parsing library via a source command into your source code, or you can call the bash parsing library with your source code as the argument. In the latter case, you if you call the library with the argument 'foo' then the output file will be called 'foo.out' and it shall be a standalone version of script 'foo' with all of the parsing functions included within it. A caveat, if you use the latter medthod, then you may __*ONLY*__ use string literals as your argumnets to the various `BAP_` functions.

# Restrictions on Public API Function Arguments
- `command` and `opt_name` must be valid Bash variable names
- `opt_arg_type` is only `existent_file` as of now. This creates a check that a provided argument is a file that exists

# Function Docs
- `BAP_new_command(new_command)`: must be the first in a series of calls to the other functions. This function sets up various internal data structures.

- `BAP_set_top_level_cmd_name(command, top_level_cmd_name)`: Adds a top-level name to a command. For instance, if you make sub commands `foo`, `bar`, and `baz` and you want them all to be sub commands of `qux`, you would use this function. The result will be usage text which prefixes the top-level command to the sub commands. like so: `Usage: qux foo`.

- `BAP_add_required_short_opt(command, opt_letter, opt_name)`: This function adds a new non-optional short option to a given command. The `opt_letter` is the letter of the short option and the `opt_name` is the text that will describe the argument of the short option. Exmaple: given a command foo where you want to add a short option of `-c <config>`: `BAP_add_required_short_opt foo c config`.

- `BAP_add_optional_short_opt(command, opt_letter, opt_name)`: Same usage as `BAP_add_required_short_opt(command, opt_letter, opt_name)`, but the option is not required.

- `BAP_set_opt_arg_type(command, opt_name, opt_arg_type)`: This function is used to enforce restrictions upon option arguments. The only type option currently is `existent_file`, which requires that the option argument provided is a file which exists.

- `BAP_add_short_opt_help_text(opt_letter, help_text)`: Help text options generate some interesting behavior. By default, there is not -h option for a command unless at least one of its opts has help text associated with it. This is done by calling `BAP_add_short_opt_help_text`. Another side affect of calling this function is that the top_level_cmd_parser, if you choose to generate one, will now contain a -h option if any of its sub commands have options. Further, the top_level command parsers' help text will display the union of all options for all sub commands. Also, help text is shared between all commands which have the same opt_letter parameters.

- `BAP_generate_parse_func(command)`: When one is all done setting up parameters for a command, one should call this function to generate a new function which will parse the arguments. Given an argument of `foo` for parameter `command`, a function named `parse_foo_args` will be produced. This new function will return a string which when `eval-ed` will insert local varaibles corrsponding to option names into the current function.

- `BAP_generate_top_level_cmd_parser(top_level_cmd_name)`: This command will automatically generate a parser which will delegate to sub parser handling functions for each sub command. See examples.


# Examples
All examples mentioned here are contained within the `examples` folder

## file: greet_req_arg
```bash
$ ./greet_req_arg 
Usage: greet -w <whom>
$ ./greet_req_arg -w
fatal: <whom> required.
Usage: greet -w <whom>
$ ./greet_req_arg -w Pete
Hello, Pete!
```

## file: greet_opt_arg_and_help
```bash
$ ./greet_opt_arg_and_help 
Hello, you!
$ ./greet_opt_arg_and_help -h
Usage: greet [-h] [-w <whom>]

Options:
  -w    The persom whom should be greeted.

$ ./greet_opt_arg_and_help -w
fatal: <whom> required.
Usage: greet [-h] [-w <whom>]
$ ./greet_opt_arg_and_help -w Pete
Hello, Pete!
```

## file: greet_sub_commands
```bash
$ ./greet_sub_commands
Usage:
  greet santa [-h] [-w <whom>]
  greet mom [-h] -w <whom>

Options:  -w    The person whom should be greeted.
$ ../src/bash_arg_parser ./greet_sub_commands
$ vim greet_sub_commands.out 
$ rm greet_sub_commands.out 
$ vim greet_sub_commands
$ ./greet_sub_commands
Usage:
  greet santa [-h] [-w <whom>]
  greet mom [-h] -w <whom>

Options:
  -w    The person whom should be greeted.
$ ./greet_sub_commands santa
Santa is sad and alone since there is noone to greet. You are a monster.
Remaining arguments: 
$ ./greet_sub_commands santa 1 2 3
Santa is sad and alone since there is noone to greet. You are a monster.
Remaining arguments: 1 2 3
$ ./greet_sub_commands santa -w
fatal: <whom> required.
Usage: greet santa [-h] [-w <whom>]
$ ./greet_sub_commands santa -w Pete
Santa put Pete on his naughty list!
Remaining arguments: 
$ ./greet_sub_commands santa -w Pete foo bar
Santa put Pete on his naughty list!
Remaining arguments: foo bar
$ ./greet_sub_commands santa -h
Usage: greet santa [-h] [-w <whom>]

Options:
  -w    The person whom should be greeted.

$ ./greet_sub_commands mom
Usage: greet mom [-h] -w <whom>
$ ./greet_sub_commands mom -w Pete
Mom loves you, Pete!
Remaining arguments: 
$ ./greet_sub_commands mom -w Pete gh
Mom loves you, Pete!
Remaining arguments: gh
$ ./greet_sub_commands mom -h 
Usage: greet mom [-h] -w <whom>

Options:
  -w    The person whom should be greeted.
```
