---
title: LocalAuthentication
---

Use FaceID and TouchID (iOS) or the Fingerprint API (Android) to authenticate the user with a face or fingerprint scan.

### `Expo.LocalAuthentication.hasHardwareAsync()`

Determine whether a face or fingerprint scanner is available on the device.

#### Returns

Returns a promise resolving to boolean value indicating whether a face or fingerprint scanner is available on this device.

### `Expo.LocalAuthentication.isEnrolledAsync()`

Determine whether the device has saved fingerprints or facial data to use for authentication.

#### Returns

Returns a promise resolving to boolean value indicating whether the device has saved fingerprints or facial data for authentication.

### `Expo.LocalAuthentication.authenticateAsync()`

Attempts to authenticate via Fingerprint (or FaceID on iPhone X).

> **Note:** When using the fingerprint module on Android, you need to provide a UI component to prompt the user to scan their fingerprint, as the OS has no default alert for it.

> **Note:** Apple requires apps which use FaceID to provide a description of why they use this API. If you try to use FaceID on an iPhone with FaceID without providing `infoPlist.NSFaceIDUsageDescription` in `app.json`, the module will authenticate using device passcode. For more information about usage descriptions on iOS, see [Deploying to App Stores](../distribution/app-stores#system-permissions-dialogs-on-ios).

#### Arguments

- (**iOS only**) **promptMessage (_string_)** A message that is shown alongside the TouchID or FaceID prompt.

#### Returns

Returns a promise resolving to an object containing `success`, a boolean indicating whether or not the authentication was successful, and `error` containing the error code in the case where authentication fails.

### `Expo.LocalAuthentication.cancelAuthenticate() - (Android Only)`

Cancels the fingerprint authentication flow.
