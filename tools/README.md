# Expo Tools

## Publishing packages

To publish Expo packages to npm registry, it's recommended to use `gulp publish-packages` script within `tools` folder.
This script helps in doing a lot of publishing stuff like handling dependency versions in packages that depend on themselves,
updating Android and iOS projects for Expo Client, committing changes that were made by the script and finally publishing.

> This script is still in beta phase, so it's recommended to run the proper command with `--dry` flag to test whether everything was done correctly.

### Available flags

-   **tag** -- npm tag to use when publishing packages. Defaults to `latest`. Use `next` if you're publishing release candidates.
-   **release** -- specifies how to bump current versions to the new one. Possible values: `patch`, `minor`, `major`. Defaults to `patch`.
-   **prerelease** -- if used, the default new version will be a prerelease version like `1.0.0-rc.0`. You can pass another string if you want another prerelease identifier than `rc`.
-   **version** -- imposes given version as a default version for all packages.
-   **force** -- force all packages to be published, even if there were no changes since last publish.
-   **dry** -- whether to skip `npm publish` command. Despite this, some files might be changed after running this script.
-   **scope** -- comma separated names of packages to be published. By default, it's trying to publish all packages defined in `dev/xdl/src/modules/config.js`.
-   **exclude** -- comma separated names of packages to be excluded from publish. It has a higher precedence than `scope` flag.

### Usage

If you're going to release a new release candidates, you might want to use something like:

```
gulp publish-packages --tag="next" --prerelease
```
---
If you want to publish just specific packages:

```
gulp publish-packages --scope="expo-gl,expo-gl-cpp"
```
---
If you want to publish a package with specific version:

```
gulp publish-packages --version="1.2.3" --scope="expo-permissions"
```

## Versioning Android

1. Run `gulp android-add-rn-version --abi=XX.X.X` in `tools`.
2. Add the new `expoview-abiXX_X_X` project as a dependency of `android/app/build.gradle`.
3. Open `android/versioned-abis/expoview-abiXX_X_X/build.gradle` and add missing `expo-payments-stripe` and `expo-constants` dependencies.
4. Remove `abiXX_X_X/expo/modules/print/PrintDocumentAdapter*Callback.java`.
5. Fix `abiXX_X_X.….R` (compilation will error) references and change them to `abiXX_X_X.host.exp.exponent.R`.
6. Open `VersionedUtils.java` and change two last arguments of `ExponentPackage` constructor to `null`s.
7. Open `PayFlow.java` in `abiXX_X_X` and fix `BuildConfig` reference (import `abiXX_X_X.host.exp.….BuildConfig`).
8. Open `ExponentPackage.java` in `abiXX_X_X` and remove offending line with `ExponentKernelModuleProvider` in `createNativeModules`.
