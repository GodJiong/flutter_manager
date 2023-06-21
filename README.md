[中文文档](https://github.com/GodJiong/flutter_manager/blob/master/README_CN.md)


A useful command line tool for Flutter, which support Flutter component management, built-in commands and custom command etc.（一个实用的Flutter命令行工具，支持Flutter组件管理、内置命令和自定义命令等）

## Requirements

The latest release of `flutter_manager` requires Dart SDK `2.12.0` or later.

## Installation

Terminal executes the following command to activate

```
$ dart pub global activate flutter_manager
```

Learn more about activating and using packages [here](https://www.dartlang.org/tools/pub/cmd/pub-global).

## Update

The same as Installation

## Usage

```
manager <command> [arguments]
```

### The main function

The `mvm` command can uniformly manage the version number of the flutter component library and switch between local path and remote git dependencies with one click. The principle is that the tool constructs a directed acyclic graph by reading the configuration file under the `mvm` folder, and then backtracks all the paths from each child node to the root node.

The configuration file will automatically generate a template when executing `manager mvm` for the first time, or it can be created manually. It contains `module.yaml`, `version.yaml` and `delegate.yaml`, users will register and update project component information in these three files.
The role of each file is as follows:

#### module.yaml

List the dependencies of all business components (including host projects)

```yaml
yourModuleName:
  dependencies:
    - thirdPartyLibraryName
    - yourModuleName
```

#### version.yaml

Configure the version number of all dependent libraries (support version number, path and git three ways)

```yaml
version:
  thirdPartyLibraryName1: versionCode
  thirdPartyLibraryName2: git
  yourModuleName1: git
  yourModuleName2: path
```

#### delegate.yaml

Configure the actual address of git and path dependencies (`git` of the three-party library needs to be marked with `thirdParty: true`)

```yaml
# The local root path for all components
path: commonLocalRootPath
git:
  yourModuleName:
    git:
      url: ""
      ref: ""
  thirdPartyLibraryName:
    thirdParty: true
    git:
      url: ""
      ref: ""
```

**Remember, when the configuration file changes, you need to execute the `manager mvm` command again to take effect.**

When the `Execution succeed` log keyword appears on the console, it means that the task is successfully executed, and the real dependencies between project components will be printed, 
which may be different from the dependencies you configured in version.yaml, because flutter requires a certain The actual dependencies of all paths from components to host projects must be consistent. 
But you only need to pay attention to version.yaml, the log only indicates that there is a better dependency configuration.

### Other functions

Run flutter commands，such as `clean`

```
manager clean
```

Run built-in commands,such as delete a file

```
manager delete a.txt
```

Run custom commands

```
manager custom ~/currentActivity.sh
```

```
manager custom flutter pub get
```


### Finally

Each command has an abbreviation, usually the first character of the command.

You can run `manager help` get more details.

```
Global options:
-h, --help    Print this usage information.

Available commands:
  clean    run flutter clean
  custom   run a custom command or its own script
  delete   run delete file, the default is pubspec.lock
  format   run flutter format .
  mvm      flutter module version manager
  pub      run flutter pub get (note: this is a parent command)
  pure     run delete,clean and pub get in order

Run "manager help <command>" for more information about a command.

```
