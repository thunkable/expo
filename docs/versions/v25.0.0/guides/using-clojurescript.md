---
title: Using ClojureScript
old_permalink: /versions/v12.0.0/guides/using-clojurescript.html
previous___FILE: ./upgrading-expo.md
next___FILE: ./using-firebase.md
---

## Quickstart

If you're already convinced about ClojureScript and Expo and know what to do once you have figwheel running, you can just read this section. Otherwise, we encourage you to read the entire guide.

```javascript
lein new expo your-project

cd your-project && yarn install

lein figwheel

# Now in a new tab, open the project in a simulator
exp start --ios
```

> **Note:** This guide was written by [@tiensonqin](https://github.com/tiensonqin), feel free to reach out to him on the [Expo Slack](http://slack.expo.io/) if you have questions!

## Why Clojurescript?

-   First-class immutable data structures
-   Minimizing state and side-effects
-   Practicality and pragmatism are always core values of ClojureScript
-   Lisp!
-   Great JavaScript interoperability

## Why on Expo?

It all begins with a [Simple Made Easy](https://www.infoq.com/presentations/Simple-Made-Easy) design choice: **you don't write native code**.

-   You only write ClojureScript or JavaScript.
-   You don't have to install or use Xcode or Android Studio or deal with any of the platform specific configuration and project files.
-   Much easier to upgrade when there is no native code involved -- React Native JavaScript APIs are relatively stable compared to the native side. Expo will take care of upgrading the native modules and React Native versions, you only need to upgrade your ClojureScript or JavaScript code.
-   You can write iOS apps on Linux or Windows (provided that you have an iPhone to test it with).
-   It's dead simple to continually share your apps. Once you published your app, you got a link. It is up to you to share the link.

## 1. Create an Expo project

```javascript
# Default to use Reagent / Re-frame
lein new expo your-project

# Or Om Next
lein new expo your-project +om

cd your-project && yarn install
```
## 2. Checkpoint: Test your Expo setup
```javascript
lein prod-build
exp start
```
## 3. Configure the project for figwheel
### Put your IP address in .lan-ip
Edit or create the file .lan-ip. The file should simply contain your IP address.

### Set Expo Host Type to LAN
Edit the file .expo/settings.json. Set the hostType to "lan"
```javascript
"hostType": "lan"
```
## 4. Connect to a REPL

### CLI REPL

```javascript
lein figwheel
```

### Emacs REPL

1.  Invoke cider-jack-in.
2.  Run `(start-figwheel)` in the connected REPL.

### [Cursive](https://cursive-ide.com/) REPL

The first time you connect to the repl, you'll need to create a Leiningen nREPL Configuration unless you have one already.

1.  Click `Run->Edit` configurations.
2.  Click the `+` button at the top left and choose Clojure REPL.
3.  Choose a `Local REPL`.
4.  Enter a name in the Name field (e.g. "REPL").
5.  Choose the radio button `Use nREPL with Leiningen`.
6.  Click the `OK` button to save your REPL config.

Once this is done, you can connect to the REPL.

In Intellij make sure your REPL config is selected and click the green **play** button to start your REPL.

Run `(start-figwheel)` in the connected REPL.

## 5. Start Expo server

### Using `exp` CLI

```javascript
# Install exp if you have not already
npm install -g exp

# Connect to iOS simulator
exp start --ios

# Connect to iOS device
exp start

# Or connect to Android devices or simulators
exp start --android
```

Once you connect, in the Expo app on the device, disable Live Reload and Hot Reloading. For more information, see [exp Command-Line Interface](exp-cli.html#exp-cli).

### Using XDE

For more information, see [XDE tour](../introduction/xde-tour.html#xde-tour).

## 6. Publish your app

```javascript
# Generate main.js
lein prod-build

exp publish
```

This will publish your app to a persistent URL on Expo, for example: <https://expo.io/@community/startr>

## FAQ

### How do I add custom native modules?

See [How do I add custom native code to my Expo project?](../introduction/faq.html#faq).

### Does it support Google Closure advanced compilation?

It's still experimental, but it already works for multiple projects.

### Does it support source maps?

Yes.

### Can I use npm modules?

React Native uses JavascriptCore, so modules using built-in node like stream, fs, etc wont work. Otherwise, you can just require like: `(js/require "SomeModule")`.

### Do I need to restart the REPL after adding new Javascript modules or assets?

No, you do need to reload Javascript. To do that, select **Reload** from the Developer Menu. You can also press `⌘ + R` in the iOS Simulator, or press `R` twice on Android emulators.

### Will it support Boot?

Not currently, but we are working on it.
