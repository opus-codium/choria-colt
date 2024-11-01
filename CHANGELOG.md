# Changelog

## [v0.8.1](https://github.com/opus-codium/choria-colt/tree/v0.8.1) (2024-10-29)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.8.0...v0.8.1)

**Merged pull requests:**

- CLI: Fix `colt tasks show` when using it with long task names [\#34](https://github.com/opus-codium/choria-colt/pull/34) ([neomilium](https://github.com/neomilium))

## [v0.8.0](https://github.com/opus-codium/choria-colt/tree/v0.8.0) (2022-11-25)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.7.0...v0.8.0)

**Merged pull requests:**

- CLI: Summarize task status results by default [\#33](https://github.com/opus-codium/choria-colt/pull/33) ([neomilium](https://github.com/neomilium))
- CLI: Always display stderr if available [\#32](https://github.com/opus-codium/choria-colt/pull/32) ([neomilium](https://github.com/neomilium))

## [v0.7.0](https://github.com/opus-codium/choria-colt/tree/v0.7.0) (2022-09-26)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.6.0...v0.7.0)

**Fixed bugs:**

- Task: Fix IDs array processing [\#30](https://github.com/opus-codium/choria-colt/pull/30) ([neomilium](https://github.com/neomilium))

**Merged pull requests:**

- Use ActiveSuport::Cache instead our own Cache mecanism for tasks metadata [\#31](https://github.com/opus-codium/choria-colt/pull/31) ([neomilium](https://github.com/neomilium))
- Improve robustness when nodes are unhealthy [\#29](https://github.com/opus-codium/choria-colt/pull/29) ([neomilium](https://github.com/neomilium))

## [v0.6.0](https://github.com/opus-codium/choria-colt/tree/v0.6.0) (2022-05-16)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.5.1...v0.6.0)

**Merged pull requests:**

- Allow to run a task from any puppet environment [\#28](https://github.com/opus-codium/choria-colt/pull/28) ([neomilium](https://github.com/neomilium))
- CLI: Use symbol notation to target `:all` nodes [\#27](https://github.com/opus-codium/choria-colt/pull/27) ([neomilium](https://github.com/neomilium))
- CLI: Allow targeting on task status requests [\#26](https://github.com/opus-codium/choria-colt/pull/26) ([neomilium](https://github.com/neomilium))
- Fix `task status` command [\#25](https://github.com/opus-codium/choria-colt/pull/25) ([neomilium](https://github.com/neomilium))

## [v0.5.1](https://github.com/opus-codium/choria-colt/tree/v0.5.1) (2022-05-02)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.5.0...v0.5.1)

## [v0.5.0](https://github.com/opus-codium/choria-colt/tree/v0.5.0) (2022-05-02)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.4.0...v0.5.0)

**Merged pull requests:**

- Process and display RPC errors like execution errors [\#24](https://github.com/opus-codium/choria-colt/pull/24) ([neomilium](https://github.com/neomilium))
- CLI: Be more green\(washing\) [\#23](https://github.com/opus-codium/choria-colt/pull/23) ([neomilium](https://github.com/neomilium))
- CLI: Support @file notation on --targets option [\#22](https://github.com/opus-codium/choria-colt/pull/22) ([neomilium](https://github.com/neomilium))
- Do not pass explicit options to rpcclient [\#21](https://github.com/opus-codium/choria-colt/pull/21) ([smortex](https://github.com/smortex))

## [v0.4.0](https://github.com/opus-codium/choria-colt/tree/v0.4.0) (2022-04-25)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.3.0...v0.4.0)

**Merged pull requests:**

- Spec: Fix tests after duration introduction [\#20](https://github.com/opus-codium/choria-colt/pull/20) ([neomilium](https://github.com/neomilium))
- CLI: Add `colt task status` subcommand [\#19](https://github.com/opus-codium/choria-colt/pull/19) ([neomilium](https://github.com/neomilium))

## [v0.3.0](https://github.com/opus-codium/choria-colt/tree/v0.3.0) (2022-04-12)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.2.0...v0.3.0)

**Merged pull requests:**

- Improve CLI output [\#18](https://github.com/opus-codium/choria-colt/pull/18) ([neomilium](https://github.com/neomilium))
- CLI: Add an option to choose log level [\#17](https://github.com/opus-codium/choria-colt/pull/17) ([neomilium](https://github.com/neomilium))
- Improve stability, fix results retrieving [\#16](https://github.com/opus-codium/choria-colt/pull/16) ([neomilium](https://github.com/neomilium))
- CLI: Add an option to set log level [\#15](https://github.com/opus-codium/choria-colt/pull/15) ([neomilium](https://github.com/neomilium))
- Setup CI [\#14](https://github.com/opus-codium/choria-colt/pull/14) ([neomilium](https://github.com/neomilium))
- CLI: Format error [\#13](https://github.com/opus-codium/choria-colt/pull/13) ([neomilium](https://github.com/neomilium))
- CLI: Display default value if available for parameters [\#12](https://github.com/opus-codium/choria-colt/pull/12) ([neomilium](https://github.com/neomilium))
- Test CLI formatter using RSpec [\#11](https://github.com/opus-codium/choria-colt/pull/11) ([neomilium](https://github.com/neomilium))
- Colorize outputs [\#10](https://github.com/opus-codium/choria-colt/pull/10) ([neomilium](https://github.com/neomilium))
- Fix task input option parsing and task output display [\#9](https://github.com/opus-codium/choria-colt/pull/9) ([neomilium](https://github.com/neomilium))
- Implement continous result display [\#8](https://github.com/opus-codium/choria-colt/pull/8) ([neomilium](https://github.com/neomilium))
- Improve robustness on errors [\#7](https://github.com/opus-codium/choria-colt/pull/7) ([neomilium](https://github.com/neomilium))
- Minor code readability improvements [\#6](https://github.com/opus-codium/choria-colt/pull/6) ([neomilium](https://github.com/neomilium))
- Improve logging [\#5](https://github.com/opus-codium/choria-colt/pull/5) ([neomilium](https://github.com/neomilium))
- Force convertion to boolean if parameter is true/false [\#4](https://github.com/opus-codium/choria-colt/pull/4) ([neomilium](https://github.com/neomilium))
- Tasks: Autofill default values [\#3](https://github.com/opus-codium/choria-colt/pull/3) ([neomilium](https://github.com/neomilium))
- CLI: Support filter on Puppet classes [\#2](https://github.com/opus-codium/choria-colt/pull/2) ([neomilium](https://github.com/neomilium))
- Tasks: Structure data before return results [\#1](https://github.com/opus-codium/choria-colt/pull/1) ([neomilium](https://github.com/neomilium))

## [v0.2.0](https://github.com/opus-codium/choria-colt/tree/v0.2.0) (2022-03-03)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.1.1...v0.2.0)

## [v0.1.1](https://github.com/opus-codium/choria-colt/tree/v0.1.1) (2022-03-03)

[Full Changelog](https://github.com/opus-codium/choria-colt/compare/v0.1.0...v0.1.1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
