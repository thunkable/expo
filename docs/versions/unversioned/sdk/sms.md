---
title: SMS
---

Provides access to the system's UI/app for sending SMS messages.

### `Expo.SMS.isAvailableAsync()`

Determines whether SMS is available.

#### Returns

Returns a promise that resolves to a `Boolean`, indicating whether SMS is available on this device.

#### Example

```javascript
const isAvailable = await Expo.SMS.isAvailableAsync();
if (isAvailable) {
  // do your SMS stuff here
} else {
  // misfortune... there's no SMS available on this device
}
```

### `Expo.SMS.sendSMSAsync(addresses, message)`

Opens the default UI/app for sending SMS messages with prefilled addresses and message.

#### Arguments

-  **addresses(_Array<string>|string_)** -- An array of addresses (_phone numbers_) or single address passed as strings. Those would appear as recipients of the prepared message.

-  **message(_string_)** -- Message to be sent

#### Returns

Returns a `Promise` that resolves when the SMS action is invoked by the user, with corresponding result:

- If the user cancelled the SMS sending process: `{ result: 'cancelled' }`.
- If the user has sent/scheduled message for sending: `{ result: 'sent' }`.
- If the status of the SMS message cannot be determined: `{ result: 'unknown' }`.

Android does not provide information about the status of the SMS message, so on Android devices the `Promise` will always resolve with `{ result: 'unknown' }`.

**_Note_**: The only feedback collected by this module is whether any message has been sent. That means we do not check actual content of message nor recipients list.


#### Example

```javascript
const { result } = await Expo.SMS.sendSMSAsync(['0123456789', '9876543210'], 'My sample HelloWorld message');
```
