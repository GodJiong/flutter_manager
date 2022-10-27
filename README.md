A useful command line tool for Dart, which support common flutter commands, built-in commands and custom command etc.

## Requirements

The latest release of `power_command` requires Dart SDK `2.12.0` or later.

## Installation

`power_command` is not meant to be used as a dependency. Instead, it should be ["activated"](https://www.dartlang.org/tools/pub/cmd/pub-global#activating-a-package).

```
$ dart pub global activate power_command
```

Learn more about activating and using packages [here](https://www.dartlang.org/tools/pub/cmd/pub-global).

## Update

The same as Installation

## Usage

Standard usage is as follows:

```
power_command <command> [arguments]
```

Run flutter commands as flollows: 

```
power_command clean
```

Run built-in commands as flollows: 

```
power_command delete a.txt
```

Run custom commands as flollows: 

```
power_command custom ~/currentActivity.sh
```

```
power_command custom flutter pub get
```

Note: 

Each command has an abbreviation, usually the first character of the command.

You can run `power_command help` get more details.

```
Global options:
-h, --help    Print this usage information.

Available commands:
  clean    run flutter clean
  custom   run a custom command or its own script
  delete   run delete file, the default is pubspec.lock
  format   run flutter format .
  pub      run flutter pub get (note: this is a parent command)
  pure     run delete,clean and pub get in order

Run "power_command help <command>" for more information about a command.

```
