import React from 'react';
import { Alert, ScrollView } from 'react-native';
import { Permissions, Notifications } from 'expo';
import HeadingText from '../components/HeadingText';
import ListButton from '../components/ListButton';

import registerForPushNotificationsAsync from '../api/registerForPushNotificationsAsync';

export default class NotificationScreen extends React.Component {
  static navigationOptions = {
    title: 'Notifications',
  };

  render() {
    return (
      <ScrollView style={{ padding: 10 }}>
        <HeadingText>Local Notifications</HeadingText>
        <ListButton
          onPress={this._presentLocalNotificationAsync}
          title="Present a notification immediately"
        />
        <ListButton
          onPress={this._scheduleLocalNotificationAsync}
          title="Schedule notification for 10 seconds from now"
        />
        <ListButton
          onPress={this._scheduleLocalNotificationAndCancelAsync}
          title="Schedule notification for 10 seconds from now and then cancel it immediately"
        />
        <ListButton
          onPress={Notifications.cancelAllScheduledNotificationsAsync}
          title="Cancel all scheduled notifications"
        />
        <ListButton
          onPress={this._scheduleLegacyNotificationAsync}
          title="Schedule a notification with both `time` and `repeat` (deprecated on iOS)"
        />
        <ListButton
          onPress={this._scheduleAndCancelLegacyNotificationAsync}
          title="Schedule and immediately cancel notification with both `time` and `repeat` (deprecated on iOS)"
        />

        <HeadingText>Push Notifications</HeadingText>
        <ListButton onPress={this._sendNotificationAsync} title="Send me a push notification" />

        <HeadingText>Custom notification categories</HeadingText>
        <ListButton
          onPress={this._createCategoryAsync}
          title="Create a custom 'message' category"
        />
        <ListButton
          onPress={this._scheduleLocalNotificationWithCategoryAsync}
          title="Schedule notification for 10 seconds from now with a 'message' category"
        />
        <ListButton
          onPress={this._deleteCategoryAsync}
          title="Delete the custom 'message' category"
        />

        <HeadingText>Badge Number</HeadingText>
        <ListButton
          onPress={this._incrementIconBadgeNumberAsync}
          title="Increment the app icon's badge number"
        />
        <ListButton onPress={this._clearIconBadgeAsync} title="Clear the app icon's badge number" />
      </ScrollView>
    );
  }

  _obtainUserFacingNotifPermissionsAsync = async () => {
    let permission = await Permissions.getAsync(Permissions.USER_FACING_NOTIFICATIONS);
    if (permission.status !== 'granted') {
      permission = await Permissions.askAsync(Permissions.USER_FACING_NOTIFICATIONS);
      if (permission.status !== 'granted') {
        Alert.alert(`We don't have permission to present notifications.`);
      }
    }
    return permission;
  };

  _obtainRemoteNotifPermissionsAsync = async () => {
    let permission = await Permissions.getAsync(Permissions.NOTIFICATIONS);
    if (permission.status !== 'granted') {
      permission = await Permissions.askAsync(Permissions.NOTIFICATIONS);
      if (permission.status !== 'granted') {
        Alert.alert(`We don't have permission to receive remote notifications.`);
      }
    }
    return permission;
  };

  _presentLocalNotificationAsync = async () => {
    await this._obtainUserFacingNotifPermissionsAsync();
    Notifications.presentLocalNotificationAsync({
      title: 'Here is a local notification!',
      body: 'This is the body',
      data: {
        hello: 'there',
      },
      ios: {
        sound: true,
      },
      android: {
        vibrate: true,
      },
    });
  };

  _scheduleLocalNotificationAsync = async () => {
    await this._obtainUserFacingNotifPermissionsAsync();
    Notifications.scheduleLocalNotificationAsync(
      {
        title: 'Here is a scheduled notifiation!',
        body: 'This is the body',
        data: {
          hello: 'there',
          future: 'self',
        },
        ios: {
          sound: true,
        },
        android: {
          vibrate: true,
        },
      },
      {
        time: new Date().getTime() + 10000,
      }
    );
  };

  _createCategoryAsync = () =>
    Notifications.createCategoryAsync('message', [
      {
        actionId: 'dismiss',
        buttonTitle: 'Dismiss notification',
        isDestructive: true,
        isAuthenticationRequired: false,
      },
      {
        actionId: 'respond',
        buttonTitle: 'Respond',
        isDestructive: false,
        isAuthenticationRequired: true,
        textInput: {
          submitButtonTitle: 'Send',
          placeholder: 'Response',
        },
      },
    ]);

  _deleteCategoryAsync = () => Notifications.deleteCategoryAsync('message');

  _scheduleLocalNotificationWithCategoryAsync = async () => {
    await this._obtainUserFacingNotifPermissionsAsync();

    await Notifications.scheduleLocalNotificationAsync(
      {
        title: 'Expo sent you a message!',
        body: 'Howdy, fella!',
        ios: {
          sound: true,
        },
        android: {
          vibrate: true,
        },
        categoryId: 'message',
      },
      {
        time: new Date().getTime() + 10000,
      }
    );
  };

  _scheduleLocalNotificationAndCancelAsync = async () => {
    await this._obtainUserFacingNotifPermissionsAsync();
    const notificationId = await Notifications.scheduleLocalNotificationAsync(
      {
        title: 'This notification should not appear',
        body: 'It should have been cancelled. :(',
        ios: {
          sound: true,
        },
        android: {
          vibrate: true,
        },
      },
      {
        time: new Date().getTime() + 10000,
      }
    );
    await Notifications.cancelScheduledNotificationAsync(notificationId);
  };

  _scheduleLegacyNotificationAsync = async () => {
    await this._obtainUserFacingNotifPermissionsAsync();
    return await Notifications.scheduleLocalNotificationAsync(
      {
        title: 'Repeating notification',
        body: `I repeat every minute starting from ${new Date().toLocaleTimeString()}`,
        data: {
          repeatingEvery: "minute",
          scheduledAt: new Date().toLocaleTimeString(),
        },
        ios: {
          sound: true,
          categoryId: 'message',
        },
        android: {
          vibrate: true,
        },
      },
      {
        time: new Date().getTime() + 2000,
        repeat: 'minute',
      }
    );
  };

  _scheduleAndCancelLegacyNotificationAsync = async () => {
    const notificationId = await this._scheduleLegacyNotificationAsync();
    await Notifications.cancelScheduledNotificationAsync(notificationId);
  };

  _incrementIconBadgeNumberAsync = async () => {
    let currentNumber = await Notifications.getBadgeNumberAsync();
    await Notifications.setBadgeNumberAsync(currentNumber + 1);
    let actualNumber = await Notifications.getBadgeNumberAsync();
    Alert.alert(`Set the badge number to ${actualNumber}`);
  };

  _clearIconBadgeAsync = async () => {
    await Notifications.setBadgeNumberAsync(0);
    Alert.alert(`Cleared the badge`);
  };

  _sendNotificationAsync = async () => {
    const permission = await this._obtainRemoteNotifPermissionsAsync();
    if (permission.status === 'granted') {
      registerForPushNotificationsAsync().done();
    }
  };
}
