# 0.0.5

* Support the function of automatically git clone flutter component source code to `path`  by `git` configuring

  ```
  bangmai_module_base:
    active: false
    path: module/bangmai_module_base
    git:
      url: 'git@xxx.git'
      ref: 'dev'
  ```

# 0.0.4

* Support flutter component source code management through a pair of commands：

  `power_command source build` 

  `power_command source restore`

# 0.0.3

* support run a script

  For Example:

  `power_command custom ~/currentActivity.sh`

# 0.0.2+2

* refactor `power_command custom --command` command to `power_command custom [arguments]`

  For Example:

  `power_command custom flutter pub get` which will run `flutter pub get`

* support to delete files or folder.

  For Example:

  print `power_command delete pubspec.lock` which will run `delete` command to delete `pubspec.lock`

# 0.0.2+1

* add custom command and format command, you can custom command like `power_command custom --command="flutter pub get"`
* every command support format flag

# 0.0.2

* fix a bug "The Flutter SDK is not available." when run command `power_command <command>`

# 0.0.1+1

* update documentation

# 0.0.1

* support `flutter clean`, `flutter pub get` , delete `pubspec.lock`file, and `pure` which run delete clean and pub get in order 