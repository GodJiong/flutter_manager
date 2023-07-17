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

**The biggest advantage of this library is:**

1. Low cost of use. Since it is a command-line tool, you only need to execute `manager mvm` once when adding or deleting dependent libraries or updating the library version number

2. Low cost of retrofit. The original componentization solution hardly needs to be moved, just configure the project structure and dependencies in the `mvm` configuration folder, and the tool will automatically identify and manage it

3. Users do not need to manually add or delete dependent libraries or update the version number to the submodule, just modify it in the unified configuration file `mvm`, and the tool will automatically locate and update under the correct module. Especially when switching between git and path dependencies, there is no need to repeat the tedious search process

4. The dependencies of each module on the third-party library are independent of each other, so a unified underlying module is not necessary, and it is truly `componentization`

5. The management of the version number of the dependent library by the configuration file `version.yaml` is shared by the entire project, that is, each submodule uses a unified version of the third-party library to avoid version conflicts

6. The local/remote branch of each component can be managed uniformly through the `ref` tag of the `delegate.yaml` configuration file

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

Configure the actual address of git and path dependencies

```yaml
# The local root path for all components
path: commonLocalRootPath
git:
  yourModuleName:
    git:
      url: ""
      #The branch of this component
      ref: ""
  thirdPartyLibraryName:
    git:
      url: ""
      ref: ""
```

**Remember, when the configuration file changes, you need to execute the `manager mvm` command again to take effect.**

When the `Execution succeed` log keyword appears on the console, it means that the task is successfully executed, and the real dependencies between project components will be printed, 
which may be different from the dependencies you configured in version.yaml, because flutter requires a certain The actual dependencies of all paths from components to host projects must be consistent. 
But you only need to pay attention to version.yaml, the log only indicates that there is a better dependency configuration.

You can run the `example` sample experience.

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
