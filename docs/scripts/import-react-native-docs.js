#!/usr/bin/env node

let path = require('path');

let minimist = require('minimist');
let fsExtra = require('fs-extra');

let args = minimist(process.argv.slice(2));

let from = args._[0] || path.join(__dirname, '..', 'react-native-website');
let to = args._[1] || path.join(__dirname, '..');
let version = args._[2] || 'unversioned';
let toVersion = path.join(to, 'versions', version);

let docsFrom = path.join(from, 'docs/');
let sidebarsJson = path.join(from, 'website', 'sidebars.json');

let reactNative = path.join(toVersion, 'react-native');

let mainAsync = async () => {
  // Go through each file and fix them
  let files = await fsExtra.readdir(to);

  let sidebarInfo = await fsExtra.readJson(sidebarsJson);
  let guides = sidebarInfo.docs.Guides;
  let components = sidebarInfo.docs.Components;
  let apis = sidebarInfo.docs.APIs;
  let basics = sidebarInfo.docs['The Basics'];

  await fsExtra.ensureDir(reactNative);

  let transformFileAysnc = async (src, dest) => {
    let basename = path.basename(src);
    switch (basename) {
      case 'getting-started.md':
      case 'getting-started.md':
      case 'more-resources.md':
      case 'appregistry.md':
      case 'geolocation.md':
      case 'building-for-apple-tv.md':
      case 'components-and-apis.md':
      case 'debugging.md':
      case 'integration-with-existing-apps.md':
      case 'running-on-device.md':
      case 'troubleshooting.md':
      case 'upgrading.md':
      case 'improvingux.md':

      // Things that maybe should just have a note telling people about the better Expo version?
      // TODO: Maybe do that?
      case 'imageeditor.md':
      case 'imagepickerios.md':
      case 'cameraroll.md':
      case 'linking.md':
      case 'permissionsandroid.md':
      case 'pushnotificationios.md':
        console.log('Skipping ' + basename);
        return;
    }

    let s = '';
    let contents = await fsExtra.readFile(src, 'utf8');
    let lines = contents.split('\n');
    let inCodeBlock = false;

    let inAlertSpecialSection = false;

    for (let l of lines) {
      l = l.replace('```ReactNativeWebPlayer', '```javascript');
      // TODO: Make this work with Snack :/
      l = l.replace(/```SnackPlayer.*$/, '```javascript');
      l = l.replace(
        '(more-resources.md)',
        '(https://facebook.github.io/react-native/docs/more-resources.html)'
      );

      // TODO: Make these global replaces instead of just first instance
      l = l.replace(
        '<img src="/react-native/docs/assets/',
        '<img src="https://facebook.github.io/react-native/docs/assets/'
      );
      l = l.replace('![](/react-native/docs/', '![](https://facebook.github.io/react-native/docs/');

      l = l.replace(
        /!\[([^]]*)\]\(\/react-native\/docs\//g,
        (match, $1) => '![' + $1 + '](https://facebook.github.io/react-native/docs/'
      );

      let r = new RegExp('!\\[(.*)\\]\\(\\/react\\-native\\/docs\\/', 'g');
      l = l.replace(
        r,
        (match, $1) => '![' + $1 + '](https://facebook.github.io/react-native/docs/'
      );

      switch (basename) {
        default:
          if (/^```/.test(l)) {
            if (!inCodeBlock) {
              if (l === '```') {
                l = l.replace(/```\s*$/, '```javascript');
              }
            }
            l = '\n' + l + '\n';
            inCodeBlock = !inCodeBlock;
          }
          break;
      }

      if (!inCodeBlock) {
        let nl = '';
        let inInlineCodeBlock = false;
        for (let c of l) {
          let nc = c;
          if (c === '`') {
            inInlineCodeBlock = !inInlineCodeBlock;
          }
          if (!inInlineCodeBlock) {
            switch (c) {
              case '<':
                if (l.indexOf('|') < 0) {
                  break;
                }
              case '{':
              case '}':
                // case '>':
                nc = '${"' + c + '"}';
                break;
              default:
                nc = c;
                break;
            }
          }
          nl += nc;
        }
        l = nl;
      }

      if (basename === 'alert.md') {
        if (l === '</table>') {
          inAlertSpecialSection = false;

          l =
            '#### iOS Alert Example\n\n![iOS Alert Example](https://facebook.github.io/react-native/docs/assets/Alert/exampleios.gif)' +
            '\n';
          l +=
            '#### Android Alert Example\n\n![Android Alert Example](https://facebook.github.io/react-native/docs/assets/Alert/exampleandroid.gif)';
        }
        if (l === '<table>') {
          inAlertSpecialSection = true;
        }
        if (inAlertSpecialSection) {
          l = '';
        }
      }

      if (basename === 'image.md') {
        l = l.replace(/^> /, ' ');
      }
      if (basename === 'flatlist.md') {
        if (/Minimal /.test(l)) {
          l = l + '\n\n```javascript';
          inCodeBlock = true;
        }
        if (/More complex, multi-select example/.test(l)) {
          l = '```\n\n' + l;
          inCodeBlock = false;
        }

        if (/class MyListItem extends/.test(l)) {
          l = '```javascript\n' + l;
          inCodeBlock = true;
        }

        if (/This is a convenience wrapper/.test(l)) {
          l = '```\n\n' + l;
          inCodeBlock = false;
        }
      }

      if (basename === 'picker.md') {
        if (/    <Picker$/.test(l)) {
          l = '\n```javascript\n\n' + l;
          inCodeBlock = true;
        }
        if (/    <\/Picker>/.test(l)) {
          l = l + '\n\n```\n';
          inCodeBlock = false;
        }
      }

      if (basename === 'segmentedcontrolios.md') {
        if (/<SegmentedControlIOS/.test(l)) {
          l = '\n' + l;
        }
        if (l.startsWith('/>')) {
          l = l + '\n';
        }
      }

      if (basename === 'layoutanimation.md') {
        if (/UIManager.setLayoutAnimationEnabledExperimental/.test(l)) {
          l = '\n```java\n' + l + '\n```\n';
        }
      }

      if (basename === 'javascript-environment.md') {
        l = l.replace(
          "`` var who = 'world'; var str = `Hello ${who}`; ``",
          "``` var who = 'world'; var str = `Hello ${who}`; ```"
        );
      }

      switch (basename) {
        case 'touchablewithoutfeedback.md':
          if (l.startsWith('#')) {
            l = l.replace(/`/g, '');
          }
          break;
        default:
          break;
      }

      if (l.startsWith('|')) {
      }

      s += l + '\n';
    }

    await fsExtra.writeFile(dest, s, 'utf8');
    // console.log(src, "->", dest);
    console.log('Wrote ' + basename);
  };

  let copyFilesAsync = async (x, destDir) => {
    for (let i = 0; i < x.length; i++) {
      let src = path.join(docsFrom, x[i]) + '.md';
      let dest = path.join(destDir, x[i]) + '.md';
      await transformFileAysnc(src, dest);
    }
  };

  for (let [x, dest] of [
    [guides, reactNative],
    [components, reactNative],
    [basics, reactNative],
    [apis, reactNative],
  ]) {
    await copyFilesAsync(x, dest);
  }

  console.log(
    '#guides',
    guides.length,
    '#components',
    components.length,
    '#apis',
    apis.length,
    '#basics',
    basics.length
  );
};

if (require.main === module) {
  (() => {
    mainAsync()
      .then(() => {
        // done
      })
      .catch(err => {
        console.error('Error: ' + err);
      });
  })();
}
