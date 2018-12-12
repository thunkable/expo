# expo-firebase-analytics

`expo-firebase-analytics`

[**Full documentation**](https://rnfirebase.io/docs/master/analytics/reference/analytics)

## Installation

Now, you need to install the package from `npm` registry.

`npm install expo-firebase-analytics` or `yarn add expo-firebase-analytics`

### iOS

#### Cocoapods

If you're using Cocoapods, add the dependency to your `Podfile`:

```ruby
pod 'EXFirebaseAnalytics', path: '../node_modules/expo-firebase-analytics/ios'
```

and run `pod install`.

#### Manually

You could also choose install this module manually.

1.  In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2.  Go to `node_modules` ➜ `expo-firebase-analytics` and add `EXFirebaseAnalytics.xcodeproj`
3.  In XCode, in the project navigator, select your project. Add `libEXFirebaseAnalytics.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4.  Run your project (`Cmd+R`).

#### Common Setup

**Optional: Enable AdSupport**

To get extra features like `audiences`, `campaign attribution`, and some `user properties`, such as `Age` and `Interests`, you will need to include AdSupport.
This isn't in by default as Apple & Google are strict with this library.

To enable the AdSupport framework:

- In your Xcode project, select your project's target
- Select the General tab for your target
- Expand the Linked Frameworks and Libraries section
- Click `+` to add a framework
- Select `AdSupport.framework`

[Learn more in the Firebase Docs](https://firebase.google.com/support/guides/analytics-adsupport)

### Android

1.  Append the following lines to `android/settings.gradle`:

    ```gradle
    include ':expo-firebase-analytics'
    project(':expo-firebase-analytics').projectDir = new File(rootProject.projectDir, '../node_modules/expo-firebase-analytics/android')
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
    api project(':expo-firebase-analytics')
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
    import expo.modules.firebase.analytics.FirebaseAnalyticsPackage;

    // Later in the file...

    @Override
    public List<Package> expoPackages() {
      // Here you can add your own packages.
      return Arrays.<Package>asList(
        new FirebaseAppPackage(), // This should be here for all Expo Firebase features.
        new FirebaseAnalyticsPackage() // Include this.
      );
    }
    ```

## Usage

```javascript
import React from 'react';
import { View } from 'react-native';
import firebase from 'expo-firebase-app';
// Include the module before using it.
import 'expo-firebase-analytics';
// API can be accessed with: firebase.analytics();

export default class DemoView extends React.Component {
  async componentDidMount() {
    firebase.analytics().logEvent('component_mounted', { foo: 'bar' });
  }

  render() {
    return <View />;
  }
}
```

### React Navigation

You can track the screens your users are interacting with by integrating the popular navigation library `react-navigation`.

[Read more about how this works](https://reactnavigation.org/docs/en/screen-tracking.html)

```js
import React from 'react';
// Import Navigation
import { createBottomTabNavigator } from 'react-navigation';
// Import Firebase
import firebase from 'expo-firebase-app';
import 'expo-firebase-analytics';
// Import some screens
import HomeScreen from '../screens/HomeScreen';
import ProfileScreen from '../screens/ProfileScreen';
// Create a generic Navigator
const AppNavigator = createBottomTabNavigator({
  // The name `Profile` or `Home` are what will appear in Firebase Analytics.
  Profile: ProfileScreen,
  Home: HomeScreen,
});
// Get the current screen from the navigation state
function getActiveRouteName(navigationState) {
  if (!navigationState) return null;
  const route = navigationState.routes[navigationState.index];
  // Parse the nested navigators
  if (route.routes) return getActiveRouteName(route);
  return route.routeName;
}

export default () => (
  <AppNavigator
    onNavigationStateChange={(prevState, currentState) => {
      const currentScreen = getActiveRouteName(currentState);
      const prevScreen = getActiveRouteName(prevState);
      if (prevScreen !== currentScreen) {
        // Update Firebase with the name of your screen
        firebase.analytics().setCurrentScreen(currentScreen);
      }
    }}
  />
);
```
