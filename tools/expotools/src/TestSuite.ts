import path from 'path';
import JsonFile from '@expo/json-file';
import spawnAsync from '@expo/spawn-async';

import * as Directories from './Directories';
import * as Log from './Log';
import * as XDL from './XDL';

const CI_USERNAME = 'exponent_ci_bot';

const TEST_SUITE_DIR = path.join(Directories.getExpoRepositoryRootDir(), 'apps', 'test-suite');

async function _installTestSuiteDependenciesAsync(): Promise<void> {
  Log.collapsed(`Installing test-suite and its dependencies...`);
  // This will install test-suite, expo, and react-native in the workspace root
  await spawnAsync('yarn', ['install'], {
    cwd: Directories.getExpoRepositoryRootDir(),
    stdio: 'inherit',
  });
}

async function _publishTestSuiteNoCacheAsync(id: string, useUnversioned: boolean): Promise<void> {
  await _installTestSuiteDependenciesAsync();

  Log.collapsed('Modifying slug...');
  let appJsonFile = new JsonFile(path.join(TEST_SUITE_DIR, 'app.json'));
  let appJson = await appJsonFile.readAsync();
  appJson.expo.slug = id;
  await appJsonFile.writeAsync(appJson);

  await XDL.publishProjectWithExpoCliAsync(TEST_SUITE_DIR, {
    useUnversioned,
  });
}

export async function publishVersionedTestSuiteAsync(sdkVersion: string): Promise<void> {
  let appJsonFile = new JsonFile(path.join(TEST_SUITE_DIR, 'app.json'));
  let appJson = await appJsonFile.readAsync();
  appJson.expo.sdkVersion = sdkVersion;
  await appJsonFile.writeAsync(appJson);

  const id = `test-suite-sdk-${sdkVersion}`.replace(/\./g, '-');
  const url = `exp://exp.host/@${CI_USERNAME}/${id}`;
  await _publishTestSuiteNoCacheAsync(id, false);

  console.log(`Published test-suite to ${url}`);
}
