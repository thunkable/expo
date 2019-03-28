'use strict';

const os = require('os');
const path = require('path');
const chalk = require('chalk');
const fs = require('fs-extra');
const shell = require('shelljs');
const semver = require('semver');
const inquirer = require('inquirer');
const { Modules } = require('xdl');
const argv = require('minimist')(process.argv.slice(2));

const defaultOptions = {
  tag: 'latest',
  release: 'patch',
  prerelease: null,
  version: null,
  force: false,
  forceVersions: false,
  dry: false,
  scope: null,
  exclude: null,
};

const ROOT_DIR = path.dirname(__dirname);

// sed command differs between platforms
const SED = os.platform() === 'linux' ? 'sed' : 'gsed';

// configs for other packages that are not unimodules
const otherPackages = [
  {
    libName: 'expo',
    dir: `${ROOT_DIR}/packages/expo`,
  },
];

// list of teams owning the packages - script will ensure all of these teams are owning published packages
const TEAMS_WITH_RW_ACCESS = [
  'expo:developers',
  'expo:swm',
];

const beforePublishPipeline = [
  _preparePublishAsync,
  _bumpVersionsAsync,
  _saveGitHeadAsync,
  _prepackAsync,
];

const publishPipeline = [
  _publishAsync,
  _addPackageOwnersAsync,
  _cleanupAsync,
];

function _trimExpoDirectory(dir) {
  if (dir.startsWith(ROOT_DIR)) {
    return dir.substring(ROOT_DIR.length).replace(/^\/+/, '');
  }
  return dir;
}

async function _runPipelineAsync(pipeline, publishConfigs, options) {
  for (const action of pipeline) {
    for (const [libName, publishConfig] of publishConfigs) {
      shell.cd(publishConfig.dir);

      const newConfig = await action(publishConfig, publishConfigs, options);

      if (newConfig) {
        publishConfigs.set(libName, { ...publishConfig, ...newConfig });
      }
    }
  }
}

async function _getPackageViewFromRegistryAsync(packageName) {
  const json = await _runJSONCommand(`npm view ${packageName} --json`);

  if (json && !json.error) {
    const currentVersion = json.versions[json.versions.length - 1];
    const publishedDate = json.time[currentVersion];

    if (!publishedDate || !currentVersion) {
      return null;
    }

    json.currentVersion = currentVersion;
    json.publishedDate = new Date(publishedDate);

    return json;
  }
  return null;
}

function _gitLogWithFormat(sinceDate, format, directory) {
  const stdout = _runCommand(`git log --since="${sinceDate.toISOString()}" --pretty="format:${format}" --color ${directory}`);
  const lines = stdout.split(/\n/g);

  return {
    stdout,
    lines,
    numberOfCommits: lines.length - 1,
  };
}

function _checkNativeChangesSince(date) {
  const nativeDirsLog = _gitLogWithFormat(date, '%h', '-- ios android');
  return nativeDirsLog.numberOfCommits > 0;
}

function _listCommitsSince(date, silent = false) {
  const format = '%C(yellow)>%Creset %C(green)%an%Creset, %C(cyan)%cr%Creset, (%C(yellow)%h%Creset) %C(blue)%s%Creset';
  const log =  _gitLogWithFormat(date, format, '.');
  const rawLog = _gitLogWithFormat(date, '%h', '.');

  if (!log.stdout) {
    console.log(chalk.yellow('No new commits since last publish. 🤷‍♂️\n'));
    return { numberOfCommits: 0, firstCommit: null };
  }

  const { lines, numberOfCommits } = rawLog;
  const firstCommit = numberOfCommits > 0 ? lines[lines.length - 1] : null;

  if (!silent) {
    console.log(chalk.gray('New commits since last publish:'));
    console.log(log.stdout);
    console.log();
  }

  return { numberOfCommits, firstCommit };
}

function _isPrereleaseVersion(version) {
  const prerelease = semver.prerelease(version);
  return prerelease != null;
}

function _findDefaultVersion(packageJson, packageView, options) {
  // if packagejson.version is greater than the released version, then use this version as a default value
  // otherwise, increment the current version as patch release

  let defaultVersion = packageView ? packageView.currentVersion : packageJson.version;

  if (options.prerelease) {
    if (!packageView) {
      return `${defaultVersion}-${options.prerelease}.0`;
    }
    if (_isPrereleaseVersion(defaultVersion)) {
      // options.release doesn't matter if the current version is also prerelease
      return semver.inc(defaultVersion, 'prerelease', options.prerelease);
    }
    return semver.inc(defaultVersion, `pre${options.release}`, options.prerelease);
  }
  return packageView ? semver.inc(defaultVersion, options.release) : packageJson.version;
}

async function _checkGNUSed() {
  // this should crash on BSD sed - it means GNU sed was not installed properly.
  const { stderr } = shell.exec(`${SED} --version`, { silent: true });

  if (stderr) {
    console.error(
      chalk.red(`\nGNU version of 'sed' is required but not installed. On MacOS, run 'brew install gnu-sed' to install it.\n`),
    );
    process.exit(0);
  }
}

async function _authenticateNpm() {
  const profile = _runJSONCommand('npm profile get --json');

  if (profile.error) {
    console.log(chalk.red('\nSeems like you are not authenticated in npm. Please run `npm login` first.\n'));
    process.exit(0);
    return;
  }
  if (profile.tfa && profile.tfa.mode === 'auth-and-writes') {
    console.error(chalk.red('Looks like you are using two-factor authentication mode that is not supported by this script.'));
    console.error(chalk.red('Change your 2fa mode to "auth-only" or temporarily disable it with `npm profile disable-2fa`.'));
    process.exit(0);
    return;
  }
  return profile;
}

async function _askForVersionAsync(libName, currentVersion, defaultVersion, packageView, options) {
  if (options && options.version) {
    if (semver.valid(options.version) && (!currentVersion || semver.gt(options.version, currentVersion))) {
      return options.version;
    }
    console.log(
      `Version '${options.version}' is invalid or not greater than the published version.`
    );
  }
  if (packageView && packageView.publishedDate && _checkNativeChangesSince(packageView.publishedDate)) {
    console.log(chalk.yellow(`Detected changes in native code! Consider bumping at least minor number.`));
  }
  if (options.forceVersions) {
    return defaultVersion;
  }
  const result = await inquirer.prompt([
    {
      type: 'input',
      name: 'version',
      message: `What is the new version of ${chalk.green(libName)} package?`,
      default: defaultVersion,
      validate(value) {
        if (semver.valid(value)) {
          if (!currentVersion || semver.gt(value, currentVersion)) {
            return true;
          }
          return `Version "${value}" is not greater than the current version "${currentVersion}"!`;
        }
        return `${value} is not a valid semver version!`;
      },
    },
  ]);
  console.log();
  return result.version;
}

async function _promptAsync(message, defaultValue = true) {
  const result = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'result',
      message,
      default: defaultValue,
    },
  ]);
  return result.result;
}

async function _selectPromptAsync(message, inputs = []) {
  const result = await inquirer.prompt([
    {
      type: 'input',
      name: 'result',
      message,
      default: inputs[0],
    },
  ]);
  if (!inputs.includes(result.result)) {
    console.error(chalk.red(`Invalid option: ${result.result}`));
    return _selectPromptAsync(message, inputs);
  }
  return result.result;
}

async function _publishPromptAsync(sinceCommit) {
  const select = await _selectPromptAsync(
    `Do you want to (p)ublish these changes, show a (d)iff or (s)kip this package?`,
    ['p', 'd', 's'],
  );

  if (select === 'd') {
    // show git diff for the package

    console.log();
    _runCommand(`git diff --text --color ${sinceCommit}^ HEAD .`, false);
    console.log();

    return _publishPromptAsync();
  }
  return select === 'p';
}

function _runCommand(command, silent = true) {
  const { stderr, stdout } = shell.exec(command, { silent });

  if (stderr) {
    stderr.split(/\r?\n/g).forEach(line => {
      console.error(chalk.red('stderr >'), line);
    });
  }
  return stdout;
}

function _runJSONCommand(command) {
  return JSON.parse(_runCommand(command));
}

function _isDependencyOf(libName, packageJson) {
  const deps = ['dependencies', 'devDependencies', 'peerDependencies'];

  for (const dep of deps) {
    if (packageJson[dep] && packageJson[dep].hasOwnProperty(libName)) {
      return true;
    }
  }
  return false;
}

function _getMaintainers(packageName) {
  const maintainers = _runCommand(`npm owner ls ${packageName}`).split(/\r?\n/g);
  return maintainers.map(maintainer => maintainer.replace(/\s<.*>$/g, ''));
}

function _isMaintainer(username, packageView) {
  if (!packageView) {
    // no packageView, so this package was not published yet and everyone is an owner.
    return true;
  }
  const owners = _runCommand(`npm owner ls ${packageView.name}`).split(/\r?\n/g);
  owners.pop(); // removes empty string
  return owners.some(maintainer => {
    return maintainer.replace(/\s<.*>$/g, '') === username;
  });
}

async function _preparePublishAsync({ libName, dir }, allConfigs, options) {
  const packageJson = require(path.join(dir, 'package.json'));
  const packageView = await _getPackageViewFromRegistryAsync(libName);
  const currentVersion = packageView && packageView.currentVersion;
  const defaultVersion = _findDefaultVersion(packageJson, packageView, options);
  const isScoped = (options.scope.length === 0 || options.scope.includes(libName)) && !options.exclude.includes(libName);
  const maintainers = packageView ? _getMaintainers(libName) : [];
  const isMaintainer = !packageView || maintainers.includes(options.npmProfile.name);
  let shouldPublish = false;

  if (isScoped) {
    console.log(`Preparing ${chalk.green(libName)}... 👨‍🍳`);

    if (packageView) {
      // package is already published

      if (!isMaintainer) {
        console.log(
          chalk.red(`Looks like you are not an owner of ${chalk.green(libName)} package. You will not be able to publish it.`)
        );

        if (await _promptAsync('Do you want to retry?')) {
          return _preparePublishAsync({ libName, dir }, allConfigs, options);
        }
        if (!await _promptAsync('Do you want to skip this package and continue the script?')) {
          process.exit(0);
          return;
        }
      } else {
        console.log(
          `${chalk.green(libName)}@${chalk.red(currentVersion)} was published at ${chalk.cyan(packageView.publishedDate)}`
        );

        const { numberOfCommits, firstCommit } = _listCommitsSince(packageView.publishedDate, options.force);

        if (numberOfCommits > 0 || options.force) {
          // there are new commits since last publish
          shouldPublish = options.force || await _publishPromptAsync(firstCommit);
        } else {
          // package probably haven't changed - no new commits
          shouldPublish = await _promptAsync(
            `Seems like ${chalk.green(libName)} hasn't changed since last publish. Do you want to publish it anyway?`
          );
        }
      }
    } else {
      // package not published
      console.log(chalk.green(libName), chalk.yellow('has not been published yet.'));

      shouldPublish = options.force || await _promptAsync(
        `Do you want to publish it now?`
      );
    }
  }

  if (shouldPublish) {
    const newVersion = await _askForVersionAsync(libName, currentVersion, defaultVersion, packageView, options);

    return {
      currentVersion,
      newVersion,
      packageView,
      shouldPublish,
      packageJson,
      maintainers,
    };
  }

  return {
    currentVersion,
    newVersion: currentVersion,
    packageView,
    shouldPublish,
    packageJson,
    maintainers,
  };
}

async function _bumpVersionsAsync({ libName, dir, newVersion, shouldPublish, packageJson }, allConfigs, options) {
  if (!shouldPublish) {
    return;
  }

  console.log(`Updating versions in ${chalk.green(libName)} package... ☝️`);

  // update dependencies in package.json and yarn.lock
  for (const config of allConfigs.values()) {
    if (libName === config.libName || !_isDependencyOf(config.libName, packageJson)) {
      // skip ourselves and packages that are not a dependency
      continue;
    }

    console.log(
      `${chalk.yellow('>')} Dependency ${chalk.green(config.libName)} updated to ${chalk.red(
        config.newVersion
      )}`
    );

    // updates dependencies in package.json
    _runCommand(
      `${SED} -i -- 's/"${config.libName}": "[^"]*"/"${config.libName}": "~${config.newVersion}"/g' package.json`,
    );

    if (fs.existsSync(path.join(dir, 'yarn.lock'))) {
      const commands = [
        // updates dependencies in yarn.lock
        `${SED} -z -i -- 's/"${config.libName}@[^"]*"[:,]\\n  version "[^"]*"/"${config.libName}@~${config.newVersion}":\\n  version "${config.newVersion}"/' yarn.lock`,
        `${SED} -z -i -- 's/${config.libName}@[^:,]*[:,]\\n  version "[^"]*"/${config.libName}@~${config.newVersion}:\\n  version "${config.newVersion}"/' yarn.lock`,
        `${SED} -z -i -- 's/${config.libName} "[^"]*"/${config.libName} "~${config.newVersion}"/g' yarn.lock`,

        // updates resolved links in yarn.lock
        `${SED} -i -- 's/-\\/${config.libName}-[0-9].*\\.tgz#[^"]*"/-\\/${config.libName}-${config.newVersion}.tgz"/g' yarn.lock`,
      ];
      commands.map(_runCommand);
    }
  }

  if (fs.existsSync(path.join(dir, 'android/build.gradle'))) {
    // update version and versionName in android/build.gradle

    _runCommand(
      `${SED} -i -- "s/version\\s*=\\s*'[^']*'/version = '${newVersion}'/g" android/build.gradle`
    );
    _runCommand(
      `${SED} -i -- 's/versionName\\s*"[^"]*"/versionName "${newVersion}"/g' android/build.gradle`
    );

    console.log(chalk.yellow('>'), `Updated package version in ${chalk.magenta('android/build.gradle')}`);

    // find versionCode
    const versionCodeLine = _runCommand(`${SED} -n '/versionCode \\d*/p' android/build.gradle`);

    if (versionCodeLine) {
      const versionCodeInt = +versionCodeLine.replace(/\D+/g, '');
      const newVersionCode = 1 + versionCodeInt;

      _runCommand(
        `${SED} -i -- 's/versionCode ${versionCodeInt}/versionCode ${newVersionCode}/' android/build.gradle`
      );

      console.log(
        chalk.yellow('>'),
        `Updated version code ${chalk.cyan(versionCodeInt)} -> ${chalk.cyan(newVersionCode)}`,
        `in ${chalk.magenta('android/build.gradle')}`
      );
    }
  }

  console.log(chalk.yellow('>'), `Updated package version in ${chalk.magenta('package.json')}`);
  console.log();
  _runCommand(`npm version ${newVersion} --allow-same-version`);
}

async function _saveGitHeadAsync({ shouldPublish, dir }) {
  if (!shouldPublish) {
    return;
  }

  const packagePath = path.join(dir, 'package.json');
  const packageJson = JSON.parse(await fs.readFile(packagePath, 'utf8'));

  packageJson.gitHead = _runCommand('git rev-parse --verify HEAD').replace(/\s*$/, '');
  await fs.writeFile(packagePath, JSON.stringify(packageJson, null, 2) + '\n', 'utf8');
}

async function _prepackAsync({ libName, newVersion, shouldPublish }) {
  if (!shouldPublish) {
    return;
  }

  console.log(`Packaging ${chalk.green(libName)}... 📦`);

  // Unfortunately, pack command sends notice logs to stderr :(
  _runCommand('npm pack 2>/dev/null');

  const filename = `${libName}-${newVersion}.tgz`;

  return {
    tarball: { filename },
  };
}

async function _publishAsync({ libName, tarball, shouldPublish, newVersion }, allConfigs, options) {
  if (!shouldPublish) {
    return;
  }
  console.log(`\nPublishing ${chalk.green(libName)}... 🚀`);

  if (options.dry) {
    console.log(chalk.gray(`Publishing skipped because of --dry flag.`));
  } else {
    _runCommand(`npm_config_tag="${options.tag}" yarn publish ${tarball.filename} --tag ${options.tag} --new-version ${newVersion}`);

    // Unfortunately, `npm publish` doesn't provide --json flag, so the best way to check if it succeded
    // is to check if the new package view resolves current version to the new version we just tried publishing
    const newPackageView = await _getPackageViewFromRegistryAsync(libName);

    if (newPackageView.currentVersion === newVersion) {
      console.log(`🚀🚀 Successfully published ${chalk.green(libName)}@${chalk.red(newVersion)} 🎉🎉`);
      return { published: true };
    } else {
      console.error(chalk.red(`🚀 🌊 The rocket with ${chalk.green(libName)} fell into the ocean, but don't worry, the crew survived. 👨‍🚀`));

      if (await _promptAsync('It might be an intermittent issue. Do you confirm it has been published?')) {
        return { published: true };
      }
      if (await _promptAsync(`Do you want to retry publishing ${chalk.green(libName)}?`)) {
        return _publishAsync({ libName, tarball, shouldPublish, newVersion }, allConfigs, options);
      }
      return { published: false };
    }
  }
}

async function _addPackageOwnersAsync({ libName, published, maintainers }) {
  if (published && TEAMS_WITH_RW_ACCESS.length > 0) {
    console.log(`\nGranting ${chalk.green(libName)} read-write access to teams:`);

    for (const teamToAdd of TEAMS_WITH_RW_ACCESS) {
      _runCommand(`npm access grant read-write ${teamToAdd}`);
      console.log(chalk.yellow('+'), chalk.blue(teamToAdd));
    }
  }
}

async function _cleanupAsync({ libName, dir, tarball }) {
  if (!tarball) {
    return;
  }
  console.log(`Cleaning up ${chalk.green(libName)}... 🛁`);
  await fs.remove(path.join(dir, tarball.filename));
}

async function _gitCommitAsync(allConfigs) {
  console.log();

  if (await _promptAsync('Do you want to commit changes made by this script?')) {
    const publishedPackages = [];

    for (const { libName, dir, newVersion, shouldPublish } of allConfigs.values()) {
      if (shouldPublish) {
        shell.cd(dir);
        publishedPackages.push(`${libName}@${newVersion}`);

        // Add to git index.
        _runCommand('git add package.json');

        if (fs.existsSync(path.join(dir, 'yarn.lock'))) {
          _runCommand('git add yarn.lock');
        }
        if (fs.existsSync(path.join(dir, 'build'))) {
          // Sometimes `build` folder can be ignored by .gitignore, send errors to /dev/null
          _runCommand('git add build 2>/dev/null');
        }
        if (fs.existsSync(path.join(dir, 'android/build.gradle'))) {
          _runCommand('git add android/build.gradle');
        }
      }
    }

    const description = publishedPackages.join('\n');
    const { message } = await inquirer.prompt([
      {
        type: 'input',
        name: 'message',
        message: 'Type in commit message:',
        default: 'Update packages',
      },
    ]);

    // Add some files from iOS project that are being touched by `pod update` command
    _runCommand(`git add ${ROOT_DIR}/ios/Podfile.lock`);
    _runCommand(`git add ${ROOT_DIR}/ios/Pods`);

    // Add expoview's build.gradle in which the dependencies were updated
    _runCommand(`git add ${ROOT_DIR}/android/expoview/build.gradle`);

    _runCommand(`git commit -m "${message}" -m "${description}"`);
  }
}

async function _updatePodsAsync(allConfigs) {
  const podNames = [...allConfigs.values()]
    .filter(config => config.podName && config.shouldPublish && config.config.ios.includeInExpoClient)
    .map(config => config.podName)
    .join(' ');

  if (podNames.length === 0) {
    // no native iOS pods to update
    return;
  }
  if (await _promptAsync(`Do you want to update pods in ${chalk.magenta('expo/ios')}?`)) {
    // Go to Expo Client iOS folder
    shell.cd(`${ROOT_DIR}/ios`);

    // Update all pods that have been published
    console.log(`\nUpdating pods: ${chalk.green(podNames)}`);
    _runCommand(`pod update ${podNames} --no-repo-update`);
    // console.log('\nInstalling pods...');
    // _runCommand('pod install');
  }
}

async function _updateAndroidDependenciesAsync(allConfigs) {
  const dependencies = [...allConfigs.values()].filter(({ config, isNativeModule, shouldPublish }) => {
    const includeInExpoClient = config && config.android.includeInExpoClient;
    return includeInExpoClient && isNativeModule && shouldPublish;
  });

  if (dependencies.length === 0) {
    // no native Android dependencies to update
    return;
  }

  function updateAndroidDependenciesInFileAsync(file, dependencies) {
    for (const { libName, newVersion } of dependencies) {
      const dependencyName = `host.exp.exponent:${libName}`;

      console.log(chalk.yellow('>'), `Updating ${chalk.green(dependencyName)} dependency`);
      _runCommand(
        `${SED} -r -i -- "s/(api|compileOnly)\\s+'${dependencyName}:[^']*'/\\1 '${dependencyName}:${newVersion}'/g" ${file}`
      );
    }
  }

  if (await _promptAsync(`Do you want to update dependencies in ${chalk.magenta('expo/android/expoview/build.gradle')}?`)) {
    shell.cd(`${ROOT_DIR}/android`);

    console.log(`\nUpdating dependencies in ${chalk.magenta('android/expoview/build.gradle')}... 🐘`);

    updateAndroidDependenciesInFileAsync('expoview/build.gradle', dependencies);
    console.log();
  }

  if (await _promptAsync(`Do you want to update dependencies in ${chalk.magenta('expo/android/app/build.gradle')}?`)) {
    shell.cd(`${ROOT_DIR}/android`);

    console.log(`\nUpdating dependencies in ${chalk.magenta('android/app/build.gradle')}... 🐘`);

    updateAndroidDependenciesInFileAsync('app/build.gradle', dependencies);
    console.log();
  }
}

async function publishPackagesAsync() {
  await _checkGNUSed();
  const npmProfile = await _authenticateNpm();

  const options = { ...defaultOptions, ...argv };

  if (options.prerelease === true) {
    options.prerelease = 'rc';
  }

  if (options.scope) {
    options.scope = options.scope && options.scope.split(/\s*,\s*/g);
  } else {
    options.scope = [];
  }

  if (options.exclude) {
    options.exclude = options.exclude && options.exclude.split(/\s*,\s*/g);
  } else {
    options.exclude = [];
  }

  // pass our profile as an option to the pipelines
  options.npmProfile = npmProfile;

  const publishConfigs = new Map();
  const modules = Modules.getPublishableModules().map(module => {
    return {
      ...module,
      dir: `${ROOT_DIR}/packages/${module.libName}`,
    };
  });

  // add other packages that are not unimodules (e.g. expo)
  modules.push(...otherPackages);

  modules.forEach(module => {
    publishConfigs.set(module.libName, module);
  });

  // --list-packages option is just to debug the config with packages used by the script
  if (options['list-packages']) {
    console.log(chalk.yellow('\nList of packages used by this script... 📝\n'));

    modules.forEach(module => {
      const packageJson = require(path.join(module.dir, 'package.json'));

      console.log('📦', chalk.green(module.libName));
      console.log(chalk.yellow('>'), 'directory:', chalk.magenta(_trimExpoDirectory(module.dir)));
      console.log(chalk.yellow('>'), 'version:', chalk.red(packageJson.version));
      console.log(
        chalk.yellow('>'),
        'pod name:',
        module.podName ? chalk.green(module.podName) : chalk.gray('undefined')
      );
      console.log();
    });

    return;
  }

  console.log(chalk.yellow('\nCollecting data about packages...\n'));

  await _runPipelineAsync(beforePublishPipeline, publishConfigs, options);

  if (![...publishConfigs.values()].some(config => config.shouldPublish)) {
    console.log('\nNo packages to publish 🤷‍♂️');
    process.exit(0);
    return;
  }

  if (options.dry) {
    console.log(`\nFollowing packages would be published but you used ${chalk.gray('--dry')} flag:`);
  } else {
    console.log('\nFollowing packages will be published:');
  }

  for (const { libName, currentVersion, newVersion, shouldPublish } of publishConfigs.values()) {
    if (shouldPublish) {
      console.log(
        `${chalk.green(libName)}: ${chalk.red(currentVersion)} -> ${chalk.red(newVersion)} (${chalk.cyan(options.tag)})`
      );
    }
  }

  console.log();

  if (await _promptAsync('Is this correct? Are you ready to launch a rocket into space? 🚀')) {
    await _updatePodsAsync(publishConfigs);
    await _updateAndroidDependenciesAsync(publishConfigs);
    await _gitCommitAsync(publishConfigs);
    await _runPipelineAsync(publishPipeline, publishConfigs, options);
  } else {
    await _runPipelineAsync([_cleanupAsync], publishConfigs, options);
  }

  console.log();
}

module.exports = {
  publishPackagesAsync
};
