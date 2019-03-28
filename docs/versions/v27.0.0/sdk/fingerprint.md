---
title: Fingerprint
---

Use TouchID and FaceID (iOS) or the Fingerprint API (Android) to authenticate the user with a face or fingerprint scan.

### `Expo.Fingerprint.hasHardwareAsync()`

Determines whether a face or fingerprint scanner is available on the device.

#### Returns

- A boolean indicating whether a face or fingerprint scanner is available on this device.

### `Expo.Fingerprint.isEnrolledAsync()`

Determine whether the device has saved fingerprints or facial data to use for authentication.

#### Returns

- A boolean indicating whether the device has saved fingerprints or facial data for authentication.

### `Expo.Fingerprint.authenticateAsync()`

Attempts to authenticate via Fingerprint.
**_Android_** - When using the fingerprint module on Android, you need to provide a UI component to prompt the user to scan their fingerprint, as the OS has no default alert for it.

#### Arguments

- (**iOS only**) **promptMessage (_string_)** A message that is shown alongside the TouchID or FaceID prompt.

#### Returns

- An object containing `success`, a boolean indicating whether or not the authentication was successful, and `error` containing the error code in the case where authentication fails.

### `Expo.Fingerprint.cancelAuthenticate() - (Android Only)`

Cancels the fingerprint authentication flow.

