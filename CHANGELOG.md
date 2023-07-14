# 1.0.4

* 【bugFixed】Fixed a bug that failed to automatically create a local source folder based on `delegate.yaml`'s `path` tag
* 【feat】Remove the `thirdParty` tag to automatically identify whether it is a third-party library

# 1.0.3

* 【feat】When you update a library dependency, the granularity of operations is reduced from dependency to specific library node
* 【feat】Removes management of the Flutter SDK, allowing users to care only about their own business dependencies

# 1.0.2

* 【feat】Add example code
* 【bugFixed】Fix the problem of address mismatch when local source code depends

# 1.0.1+1

* Update Chinese document address

# 1.0.1

* The previous [power_command](https://pub.dev/packages/power_command) is no longer maintained, and new [flutter_manager](https://pub.dev/packages/flutter_manager) are welcome

# 1.0.0

* Added `manager mvm` command.The `mvm` command can uniformly manage the version number of the flutter component library and switch between local path and remote git dependencies with one click.