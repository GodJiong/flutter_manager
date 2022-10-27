A useful command line tool for Dart, which supports clean, pub get, pure etc.

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

You can run `power_command help` get more details.

```
Global options:
-h, --help    Print this usage information.

Available commands:
  clean    run flutter clean
  custom   run a custom command
  delete   run delete pubspec.lock
  format   run flutter format .
  pub      run flutter pub get (note: this is a parent command)
  pure     run delete,clean and pub get in order

Run "power_command help <command>" for more information about a command.

```
