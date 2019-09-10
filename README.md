# Devclose-Checker

[![Build Status](https://travis-ci.org/langered/devclose-checker.svg?branch=master)](https://travis-ci.org/langered/devclose-checker)

This tool provides a cli and [bitbar](https://github.com/matryer/bitbar)-plugin to check the devclose of any repository which has it defined in its description.
This tool will look for a keyword in the description and interprets the devclose.

## Prequesite

In order to activate the bitbar plugin, bitbar has to be installed. This can be
installed with:

`brew cask install bitbar`

## Installation

<!-- For the devclose-checker a homebrew tap exist. This will install CLI and the -->
<!-- bitbar plugin. -->

<!-- Add the homebrew tap by executing: -->

<!-- Install it with: -->

<!-- `bundle install devclose` -->

## Usage

### CLI

By calling without providing any flags, the cli will output following Strings, depending on the current devclose-status:

* `open`: No devclose, free for development
* `closed`: Devclose
* `unkown`: There is no information about the devclose
* `unavailable`: The repository is not available.

There are three flags to use:

1. `--json`: provides full devclose information in the JSON-format
2. `--bitbar`: provides the output in the bitbar-format
3. `--help`: shows help

### bitbar

After the devclose-checker is installed, you should see a new icon (depending on the current devclose-status) in your bar which represents the status descibed in the [CLI-section](#CLI):

* :white_check_mark: `open`
* :no_entry_sign: `closed`
* :question: `unkown`
* :boom: `unavailable`

Clicking on the icon will show you two more options:

* Open the linkt to the official repository
* Open the config file in VIM in order to change it

### Customization

With the help of a configuration file which is named `devclose_config.yml` and
is stored next to the CLI or bitbar-plugin binary in a `config`-folder, the following properties are
customizable:

* URL of the repo api

* open and close indocator strings

* emojis for each status

The configuration file looks like this:

```
repo_api: <repo api url> (required)
open_indicator: open (optional)
closed_indicator: close (optional)
emojis: (optional)
  open: ":white_check_mark:" (optional)
  closed: ":no_entry_sign:" (optional)
  unknown: ":question:" (optional)
  unavailable: ":boom:" (optional)
```

Only the URL of the Repo API is required. All other properties are optional. The
example config file above shows also the default values for the optional
properties.
