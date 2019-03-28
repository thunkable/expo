---
title: Configuring OTA Updates
---

Expo provides various settings to configure how your app receives over-the-air (OTA) JavaScript updates. OTA updates allow you to publish a new version of your app JavaScript and assets without building a new version of your standalone app and re-submitting to app stores ([read more about the limitations](publishing.html)).

OTA updates are controlled by the [`updates` settings in app.json](configuration.html#updates), which handle the initial app load, and the [Updates SDK module](../sdk/updates.html), which allows you to fetch updates asynchronously from your JS.

## Automatic Updates

By default, Expo will check for updates automatically when your app is launched and will try to fetch the latest published version. If a new bundle is available, Expo will attempt to download it before launching the experience. If there is no network connection available, or it has not finished downloading in 30 seconds, Expo will fall back to loading a cached version of your app, and continue trying to fetch the update in the background (at which point it will be saved into the cache for the next app load).

With this automatic configuration, calling [`Expo.Updates.reload()`](../sdk/updates.html#expoupdatesreload) will also result in Expo attempting to fetch the most up-to-date version of your app, so there is no need to use any of the other methods in the Updates module.

The timeout length is configurable by setting `updates.fallbackToCacheTimeout` (ms) in app.json. For example, a common pattern is to set `updates.fallbackToCacheTimeout` to `0`. This will allow your app to start immediately with a cached bundle while downloading a newer one in the background for future use. [`Expo.Updates.addListener`](../sdk/updates.html#expoupdatesaddlistenereventlistener) provides a hook to let you respond when the new bundle is finished downloading.

## Manual Updates

In standalone apps, it is also possible to turn off automatic updates, and to instead control updates entirely within your JS code. This is desirable if you want some custom logic around fetching updates (e.g. only over Wi-Fi).

Setting `updates.checkAutomatically` to `"ON_ERROR_RECOVERY"` in app.json will prevent Expo from automatically fetching the latest update every time your app is launched. Only the most recent cached version of your bundle will be loaded. It will only automatically fetch an update if the last run of the cached bundle produced a fatal JS error.

You can then use the [`Expo.Updates`](../sdk/updates.html) module to download new updates and, if appropriate, notify the user and reload the experience.

```javascript
try {
  const update = await Expo.Updates.checkForUpdateAsync();
  if (update.isAvailable) {
    await Expo.Updates.fetchUpdateAsync();
    // ... notify user of update ...
    Expo.Updates.reload();
  }
} catch (e) {
  // handle or log error
}
```

Note that `checkAutomatically: "ON_ERROR_RECOVERY"` will be ignored in the Expo client, although the imperative Updates methods will still function normally.

## Disabling Updates

It is possible to entirely disable OTA JavaScript updates in a standalone app, by setting `updates.enabled` to `false` in app.json. This will ignore all code paths that fetch app bundles from Expo's servers. In this case, all updates to your app will need to be routed through the iOS App Store and/or Google Play Store.

This setting is ignored in the Expo client.
