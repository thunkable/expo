---
title: Why not Expo?
---

Expo isn't ready to be used for all apps yet. There are plenty of cases where its current constraints may not be appropriate for your project. The intention of this document is to outline some of those cases, so that you don't end up building an app with Expo and getting frustrated when you encounter an obstacle that you can't overcome without detaching to ExpoKit or ejecting to using React Native without Expo at all. We are either planning on or actively working on building solutions to all of the features listed below, and if you think anything is missing, please bring it to our attention by posting to our [feature requests board](https://expo.canny.io/feature-requests).

- **Expo apps don't support background code execution** (running code when the app is not foregrounded or the device is sleeping). This means you cannot use background geolocation, play audio in the background, handle push notifications in the background, and more. This is a work in progress.
- Expo supports a lot of device APIs (check out the "SDK API Reference" in the sidebar), but **not all iOS and Android APIs are available in Expo**: need Bluetooth? Sorry, we haven't built support for it yet. WebRTC? Not quite. We are constantly adding new APIs, so if we don't have something you need now, you can either use ExpoKit or follow [our blog](https://blog.expo.io) to see the release notes for our monthly SDK updates.
- **If you need to keep your app size extremely lean, Expo may not be the best choice**. The size for an Expo app on iOS is approximately 25mb, and Android is about 20mb. This is because Expo includes a bunch of APIs regardless of whether or not you are using them -- this lets you push over the air updates to use new APIs, but comes at the cost of binary size. We will make this customizable in the future, so you can trim down the size of your binaries.
- **If you know that you want to use a particular push notification service** (such as OneSignal) instead of Expo's [Push Notification service/API](../guides/push-notifications.html), you will need to use ExpoKit or React Native without Expo.

Are we missing something here? Let us know [on Slack](http://slack.expo.io/) or on our [feature requests board](https://expo.canny.io/feature-requests).
