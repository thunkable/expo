#!/usr/bin/env node
/**
 * Generates the Expo jest-preset.json by deriving it from React Native's
 * jest-preset.json. This script uses the copy of RN in react-native-lab.
 */
'use strict';

const assert = require('assert');
const fs = require('fs');
const path = require('path');

function generateJestPreset() {
  // Load the React Native Jest preset
  const rnLabPath = path.resolve(__dirname, '../../../react-native-lab');
  const rnJestPresetPath = path.join(rnLabPath, 'react-native/jest-preset.json');
  const rnJestPreset = require(rnJestPresetPath);

  // Derive the Expo Jest preset from the React Native one
  const expoJestPreset = JSON.parse(JSON.stringify(rnJestPreset));

  if (expoJestPreset.haste) {
    assert(expoJestPreset.haste.hasOwnProperty('hasteImplModulePath'));
    expoJestPreset.haste.hasteImplModulePath = expoJestPreset.haste.hasteImplModulePath.replace(
      /^<rootDir>\/node_modules\//,
      ''
    );
  }

  if (!expoJestPreset.moduleNameMapper) {
    expoJestPreset.moduleNameMapper = {};
  }

  if (expoJestPreset.modulePathIgnorePatterns) {
    expoJestPreset.modulePathIgnorePatterns = expoJestPreset.modulePathIgnorePatterns.map(pattern =>
      pattern.replace(/^<rootDir>\/node_modules\//, '')
    );
  }

  if (!expoJestPreset.transform) {
    expoJestPreset.transform = {};
  }

  const defaultBabelPattern = '^.+\\.js$';
  assert(expoJestPreset.transform.hasOwnProperty(defaultBabelPattern));
  delete expoJestPreset.transform[defaultBabelPattern];

  const babelTsPattern = '^.+\\.(js|ts|tsx)$';
  expoJestPreset.transform[babelTsPattern] = 'babel-jest';

  const defaultAssetNamePattern = '^.+\\.(bmp|gif|jpg|jpeg|mp4|png|psd|svg|webp)$';
  assert(expoJestPreset.transform.hasOwnProperty(defaultAssetNamePattern));
  delete expoJestPreset.transform[defaultAssetNamePattern];

  const assetNamePattern =
    '^.+\\.(bmp|gif|jpg|jpeg|mp4|png|psd|svg|webp|ttf|otf|m4v|mov|mp4|mpeg|mpg|webm|aac|aiff|caf|m4a|mp3|wav|html|pdf|obj)$';
  expoJestPreset.transform[assetNamePattern] = 'jest-expo/src/assetFileTransformer.js';

  assert(Array.isArray(expoJestPreset.transformIgnorePatterns));
  assert.deepEqual(expoJestPreset.transformIgnorePatterns, [
    'node_modules/(?!(jest-)?react-native|react-clone-referenced-element)',
  ]);
  expoJestPreset.transformIgnorePatterns = [
    'node_modules/(?!((jest-)?react-native|react-clone-referenced-element|expo(nent)?|@expo(nent)?/.*|react-navigation|@react-navigation/.*|sentry-expo|native-base))',
  ];

  expoJestPreset.moduleFileExtensions = ['js', 'json', 'jsx', 'node', 'ts', 'tsx'];

  expoJestPreset.testMatch = ['**/__tests__/**/*.(js|ts|tsx)', '**/?(*.)+(spec|test).(js|ts|tsx)'];

  if (!expoJestPreset.setupFiles) {
    expoJestPreset.setupFiles = [];
  } else {
    expoJestPreset.setupFiles = expoJestPreset.setupFiles.map(setupFile =>
      setupFile.replace(/^<rootDir>\/node_modules\//, '')
    );
  }
  expoJestPreset.setupFiles.push('jest-expo/src/setup.js');

  // Save the Expo Jest preset
  fs.writeFileSync(
    path.resolve(__dirname, '../jest-preset.json'),
    JSON.stringify(expoJestPreset, null, 2)
  );
}

if (require.main === module) {
  generateJestPreset();
}
