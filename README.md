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
