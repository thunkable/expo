# expo-firebase-crashlytics

> expo-firebase is still in RC and therefore subject to breaking changings. Be sure to run `yarn upgrade` and `cd ios; pod install` when upgrading.

`expo-firebase-crashlytics` allows you to monitor native and non-fatal crashes.

[**Full documentation**](https://rnfirebase.io/docs/master/crashlytics/reference/crashlytics)

## Installation

Now, you need to install the package from `npm` registry.

`npm install expo-firebase-crashlytics` or `yarn add expo-firebase-crashlytics`

### iOS

#### Cocoapods

If you're using Cocoapods, add the dependency to your `Podfile`:

```ruby
pod 'EXFirebaseCrashlytics', path: '../node_modules/expo-firebase-crashlytics/ios'
```

and run `pod install`.

#### Common Setup

**Add the Crashlytics run script**

RNFirebase [**crashlytics build script**](https://rnfirebase.io/docs/master/crashlytics/ios#Add-the-Crashlytics-run-script)

1.  Open your project in Xcode and select its project file in the Navigator
2.  Open the `Build Phases` tab.
3.  Click `+` Add a new build phase, and select `New Run Script Phase`.
4.  Add the following line to the `Type a script...` text box:

    ```rb
    "${PODS_ROOT}/Fabric/run"
    ```

5.  **XCode 10 only:** Add your app's built `Info.plist` location to the Build Phase's Input Files field:
    ```rb
    $(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
    ```

### Android

1.  Append the following lines to `android/settings.gradle`:

    ```gradle
    include ':expo-firebase-crashlytics'
    project(':expo-firebase-crashlytics').projectDir = new File(rootProject.projectDir, '../node_modules/expo-firebase-crashlytics/android')
    ```

    and if not already included

    ```gradle
    include ':expo-core'
    project(':expo-core').projectDir = new File(rootProject.projectDir, '../node_modules/expo-core/android')

    include ':expo-firebase-app'
    project(':expo-firebase-app').projectDir = new File(rootProject.projectDir, '../node_modules/expo-firebase-app/android')
    ```

2.  Insert the following lines inside the dependencies block in `android/app/build.gradle`:
    ```gradle
    api project(':expo-firebase-crashlytics')
    ```
    and if not already included
    ```gradle
    api project(':expo-core')
    api project(':expo-firebase-app')
    ```
3.  Include the module in your expo packages: `./android/app/src/main/java/host/exp/exponent/MainActivity.java`

    ```java
    /*
    * At the top of the file.
    * This is automatically imported with Android Studio, but if you are in any other editor you will need to manually import the module.
    */
    import expo.modules.firebase.app.FirebaseAppPackage; // This should be here for all Expo Firebase features.
    import expo.modules.firebase.fabric.crashlytics.FirebaseCrashlyticsPackage;

    // Later in the file...

    @Override
    public List<Package> expoPackages() {
      // Here you can add your own packages.
      return Arrays.<Package>asList(
        new FirebaseAppPackage(), // This should be here for all Expo Firebase features.
        new FirebaseCrashlyticsPackage() // Include this.
      );
    }
    ```

## Usage

```javascript
import React from 'react';
import { View } from 'react-native';
import firebase from 'expo-firebase-app';

// API can be accessed with: firebase.crashlytics();

export default class DemoView extends React.Component {
  async componentDidMount() {
    // Native crash the app to test.
    firebase.crashlytics().crash();

    try {
      await someAsyncTask();
    } catch ({ message, code }) {
      // Put this in all your try/catch's to log them.
      firebase.crashlytics().recordError(code, message);
    }
  }

  render() {
    return <View />;
  }
}
```

## Trouble Shooting

You may find that the Crashlytics tab is stuck on the onboarding page in the firebase console. If this happens then make sure your Firebase app id matches Expo bundle ID/Package ID. For instance, if you start testing with `host.exp.Exponent` then detach, you will need to update the config to reflect your new ID.
