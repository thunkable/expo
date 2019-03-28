package expo.modules.firebase.notifications;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
// TODO: Bacon: Remove React Native https://github.com/expo/expo/pull/2338
import com.facebook.react.HeadlessJsTaskService;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.jstasks.HeadlessJsTaskConfig;

import static expo.modules.firebase.notifications.FirebaseBackgroundNotificationActionReceiver.isBackgroundNotficationIntent;

public class FirebaseBackgroundNotificationActionsService extends HeadlessJsTaskService {
  static WritableMap toNotificationOpenMap(Intent intent) {
    Bundle extras = intent.getExtras();
    WritableMap notificationMap = Arguments.makeNativeMap(extras.getBundle("notification"));
    WritableMap notificationOpenMap = Arguments.createMap();
    notificationOpenMap.putString("action", extras.getString("action"));
    notificationOpenMap.putMap("notification", notificationMap);
    return notificationOpenMap;
  }

  @Override
  protected @Nullable HeadlessJsTaskConfig getTaskConfig(Intent intent) {
    if (isBackgroundNotficationIntent(intent)) {
      WritableMap notificationOpenMap = toNotificationOpenMap(intent);

      return new HeadlessJsTaskConfig("FirebaseBackgroundNotificationAction", notificationOpenMap, 60000, true);
    }
    return null;
  }
}
