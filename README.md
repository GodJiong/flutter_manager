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

Run flutter commands as follows: 

```
power_command clean
```

Run built-in commands as follows: 

```
power_command delete a.txt
```

Run custom commands as follows: 

```
power_command custom ~/currentActivity.sh
```

```
power_command custom flutter pub get
```

You can also manage flutter component source code as follows：

1. Configure the source path In the `pubspec.yaml` of the main project, such as:

   ```
   source_config:
     # Loop to check whether each unique element depends on global, if it depends, ignore the active attribute of unique, 
     # the unique element directly becomes the source code to be depended on by the main project, and the unique element also depends on the global source code
     global:
       bangmai_module_base:
         active: true
         path: ../bangmai_module_base
     # Check whether the active of the unique element is activated, if it is activated, it depends on the source code
     unique:
       bangmai_module_workbench:
         active: false
         path: module/bangmai_module_workbench
       bangmai_module_mine:
         active: false
         path: module/bangmai_module_mine
   ```

2. Run `power_command source build` to build source dependencies , Then do what you want in the source code project.

3. Run `power_command source restore` to reset all yaml file configuration.

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
