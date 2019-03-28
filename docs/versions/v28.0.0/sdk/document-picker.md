---
title: DocumentPicker
---

Provides access to the system's UI for selecting documents from the available providers on the user's device.

### `Expo.DocumentPicker.getDocumentAsync(options)`

Display the system UI for choosing a document. By default, the chosen file is copied to [the app's internal cache directory](filesystem.md##expofilesystemcachedirectory).

#### Arguments

-   **options (_object_)** --

      A map of options:

    -   **type (_string_)** -- The [MIME type](https://en.wikipedia.org/wiki/Media_type) of the documents that are available to be picked. Is also supports wildcards like `image/*` to choose any image. To allow any type of document you can use `*/*`. Defaults to `*/*`.
    -   **copyToCacheDirectory (_boolean_)** -- If `true`, the picked file is copied to [`Expo.FileSystem.CacheDirectory`]((filesystem.md##expofilesystemcachedirectory)), which allows other Expo APIs to read the file immediately. Defaults to `true`. This may impact performance for large files, so you should consider setting this to `false` if you expect users to pick particularly large files and your app does not need immediate read access.

#### Returns

If the user cancelled the document picking, returns `{ type: 'cancel' }`.

Otherwise, returns `{ type: 'success', uri, name, size }` where `uri` is a URI to the local document file, `name` is its original name and `size` is its size in bytes.

## iOS configuration

On iOS, for [standalone apps](../guides/building-standalone-apps.html) and [ExpoKit](../guides/expokit.html) projects, the DocumentPicker module requires the iCloud entitlement to work properly. You need to set the `usesIcloudStorage` key to `true` in your `app.json` file as specified [here](../guides/configuration.html#ios).

### iCloud Application Service

In addition, you'll also need to enable the iCloud Application Service in your App identifier. This can be done in the detail of your [App ID in the Apple developer interface](https://developer.apple.com/account/ios/identifier/bundle).

Enable iCloud service with CloudKit support, create one iCloud Container, and name it `iCloud.<your_bundle_identifier>`.

And finally, to apply those changes, you'll need to revoke your existing provisioning profile and run `exp build:ios -c`

For ExpoKit apps, you need to open the project in Xcode and follow the [Using DocumentPicker instructions](../guides/advanced-expokit-topics.html#using-documentpicker) in the Advanced ExpoKit Topics guide.
