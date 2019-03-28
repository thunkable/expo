package expo.modules.firebase.notifications;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.RemoteInput;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import com.google.firebase.messaging.RemoteMessage;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import expo.core.ExportedModule;
import expo.core.ModuleRegistry;
import expo.core.Promise;
import expo.core.interfaces.ActivityEventListener;
import expo.core.interfaces.ActivityProvider;
import expo.core.interfaces.ExpoMethod;
import expo.core.interfaces.ModuleRegistryConsumer;
import expo.core.interfaces.services.UIManager;
import expo.modules.firebase.app.Utils;
import expo.modules.firebase.messaging.EXFirebaseMessagingService;
import me.leolin.shortcutbadger.ShortcutBadger;

import static expo.modules.firebase.app.Utils.getResId;

public class FirebaseNotificationsModule extends ExportedModule
    implements ModuleRegistryConsumer, ActivityEventListener {

  private static final String TAG = FirebaseNotificationsModule.class.getCanonicalName();
  private static final String BADGE_FILE = "BadgeCountFile";
  private static final String BADGE_KEY = "BadgeCount";
  protected static ModuleRegistry moduleRegistry;
  private SharedPreferences sharedPreferences;

  private FirebaseNotificationManager notificationManager;

  private WeakReference<ModuleRegistry> mModuleRegistry;

  public FirebaseNotificationsModule(Context context) {
    super(context);
  }

  @Override
  public String getName() {
    return "ExpoFirebaseNotifications";
  }

  @Override
  public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
    // FCM functionality does not need this function
  }

  @Override
  public void onNewIntent(Intent intent) {
    Bundle notificationOpenMap = parseIntentForNotification(intent);
    if (notificationOpenMap != null) {
      Utils.sendEvent(mModuleRegistry.get(), "Expo.Firebase.notifications_notification_opened", notificationOpenMap);
    }
  }

  @Override
  public void setModuleRegistry(ModuleRegistry moduleRegistry) {
    mModuleRegistry = new WeakReference<>(moduleRegistry);

    if (moduleRegistry != null) {
      if (notificationManager == null) {
        notificationManager = new FirebaseNotificationManager(getContext(), moduleRegistry);
      } else {
        notificationManager.mModuleRegistry = moduleRegistry;
      }
    } else {
      notificationManager = null;
    }

    sharedPreferences = getContext().getSharedPreferences(BADGE_FILE, Context.MODE_PRIVATE);
    FirebaseNotificationsModule.moduleRegistry = moduleRegistry;
    
    if (moduleRegistry != null) {
      if (moduleRegistry.getModule(UIManager.class) != null) {
        moduleRegistry.getModule(UIManager.class).registerActivityEventListener(this);
      }
      //TODO: Bacon: Unregister
      LocalBroadcastManager localBroadcastManager = LocalBroadcastManager.getInstance(getContext());

      // Subscribe to remote notification events
      localBroadcastManager.registerReceiver(new RemoteNotificationReceiver(),
              new IntentFilter(EXFirebaseMessagingService.REMOTE_NOTIFICATION_EVENT));

      // Subscribe to scheduled notification events
      localBroadcastManager.registerReceiver(new ScheduledNotificationReceiver(),
              new IntentFilter(FirebaseNotificationManager.SCHEDULED_NOTIFICATION_EVENT));
    }
  }

  protected final Context getApplicationContext() {
    Activity activity = getCurrentActivity();
    if (activity != null) {
      return activity.getApplicationContext();
    }
    return null;
  }

  protected final Activity getCurrentActivity() {
    ModuleRegistry moduleRegistry = mModuleRegistry.get();
    if (moduleRegistry != null) {
      ActivityProvider activityProvider = moduleRegistry.getModule(ActivityProvider.class);
      return activityProvider.getCurrentActivity();
    }
    return null;
  }

  @ExpoMethod
  public void cancelAllNotifications(Promise promise) {
    notificationManager.cancelAllNotifications(promise);
  }

  @ExpoMethod
  public void cancelNotification(String notificationId, Promise promise) {
    notificationManager.cancelNotification(notificationId, promise);
  }

  @ExpoMethod
  public void displayNotification(Map<String, Object> notification, Promise promise) {
    notificationManager.displayNotification(notification, promise);
  }

  @ExpoMethod
  public void getBadge(Promise promise) {
    int badge = sharedPreferences.getInt(BADGE_KEY, 0);
    Log.d(TAG, "Got badge count: " + badge);
    promise.resolve(badge);
  }

  @ExpoMethod
  public void getInitialNotification(Promise promise) {
    Bundle notificationOpenMap = null;
    if (getCurrentActivity() != null) {
      notificationOpenMap = parseIntentForNotification(getCurrentActivity().getIntent());
    }
    promise.resolve(notificationOpenMap);
  }

  @ExpoMethod
  public void getScheduledNotifications(Promise promise) {
    ArrayList<Bundle> bundles = notificationManager.getScheduledNotifications();
    List array = new ArrayList();
    for (Bundle bundle : bundles) {
      array.add(bundle);
    }
    promise.resolve(array);
  }

  @ExpoMethod
  public void removeAllDeliveredNotifications(Promise promise) {
    notificationManager.removeAllDeliveredNotifications(promise);
  }

  @ExpoMethod
  public void removeDeliveredNotification(String notificationId, Promise promise) {
    notificationManager.removeDeliveredNotification(notificationId, promise);
  }

  @ExpoMethod
  public void removeDeliveredNotificationsByTag(String tag, Promise promise) {
    notificationManager.removeDeliveredNotificationsByTag(tag, promise);
  }

  @ExpoMethod
  public void setBadge(int badge, Promise promise) {
    // Store the badge count for later retrieval
    sharedPreferences.edit().putInt(BADGE_KEY, badge).apply();
    if (badge == 0) {
      Log.d(TAG, "Remove badge count");
      ShortcutBadger.removeCount(this.getApplicationContext());
    } else {
      Log.d(TAG, "Apply badge count: " + badge);
      ShortcutBadger.applyCount(this.getApplicationContext(), badge);
    }
    promise.resolve(null);
  }

  @ExpoMethod
  public void scheduleNotification(Map<String, Object> notification, Promise promise) {
    notificationManager.scheduleNotification(notification, promise);
  }

  //////////////////////////////////////////////////////////////////////
  // Start Android specific methods
  //////////////////////////////////////////////////////////////////////
  @ExpoMethod
  public void createChannel(Map<String, Object> channelMap, Promise promise) {
    try {
      notificationManager.createChannel(channelMap);
    } catch (Throwable t) {
      // do nothing - most likely a NoSuchMethodError for < v4 support lib
    }
    promise.resolve(null);
  }

  @ExpoMethod
  public void createChannelGroup(Map<String, Object> channelGroupMap, Promise promise) {
    try {
      notificationManager.createChannelGroup(channelGroupMap);
    } catch (Throwable t) {
      // do nothing - most likely a NoSuchMethodError for < v4 support lib
    }
    promise.resolve(null);
  }

  @ExpoMethod
  public void createChannelGroups(List channelGroupsArray, Promise promise) {
    try {
    notificationManager.createChannelGroups(channelGroupsArray);
  } catch (Throwable t) {
    // do nothing - most likely a NoSuchMethodError for < v4 support lib
  }
    promise.resolve(null);
  }

  @ExpoMethod
  public void createChannels(List channelsArray, Promise promise) {
    try {

    notificationManager.createChannels(channelsArray);
  } catch (Throwable t) {
    // do nothing - most likely a NoSuchMethodError for < v4 support lib
  }
    promise.resolve(null);
  }

  @ExpoMethod
  public void deleteChannelGroup(String channelId, Promise promise) {
    try {
      notificationManager.deleteChannelGroup(channelId);
      promise.resolve(null);
    } catch (NullPointerException e) {
      promise.reject(
        "notifications/channel-group-not-found",
        "The requested NotificationChannelGroup does not exist, have you created it?"
      );
    }
  }

  @ExpoMethod
  public void deleteChannel(String channelId, Promise promise) {
    try {
    notificationManager.deleteChannel(channelId);
  } catch (Throwable t) {
    // do nothing - most likely a NoSuchMethodError for < v4 support lib
  }
    promise.resolve(null);
  }
  //////////////////////////////////////////////////////////////////////
  // End Android specific methods
  //////////////////////////////////////////////////////////////////////

  private Bundle parseIntentForNotification(Intent intent) {
    Bundle notificationOpenMap = parseIntentForRemoteNotification(intent);
    if (notificationOpenMap == null) {
      notificationOpenMap = parseIntentForLocalNotification(intent);
    }
    return notificationOpenMap;
  }

  private Bundle parseIntentForLocalNotification(Intent intent) {
    if (intent.getExtras() == null || !intent.hasExtra("notificationId")) {
      return null;
    }

    Bundle notificationOpenMap = new Bundle();
    notificationOpenMap.putString("action", intent.getAction());
    notificationOpenMap.putBundle("notification", intent.getExtras());

    // Check for remote input results
    Bundle remoteInput = RemoteInput.getResultsFromIntent(intent);
    if (remoteInput != null) {
      notificationOpenMap.putBundle("results", remoteInput);
    }

    return notificationOpenMap;
  }

  private Bundle parseIntentForRemoteNotification(Intent intent) {
    // Check if FCM data exists
    if (intent.getExtras() == null || !intent.hasExtra("google.message_id")) {
      return null;
    }

    Bundle extras = intent.getExtras();

    Bundle notificationMap = new Bundle();
    Bundle dataMap = new Bundle();

    for (String key : extras.keySet()) {
      if (key.equals("google.message_id")) {
        notificationMap.putString("notificationId", extras.getString(key));
      } else if (key.equals("collapse_key") || key.equals("from") || key.equals("google.sent_time")
          || key.equals("google.ttl") || key.equals("_fbSourceApplicationHasBeenSet")) {
        // ignore known unneeded fields
      } else {
        dataMap.putString(key, extras.getString(key));
      }
    }
    notificationMap.putBundle("data", dataMap);

    Bundle notificationOpenMap = new Bundle();
    notificationOpenMap.putString("action", intent.getAction());
    notificationOpenMap.putBundle("notification", notificationMap);

    return notificationOpenMap;
  }

  private Bundle parseRemoteMessage(RemoteMessage message) {
    RemoteMessage.Notification notification = message.getNotification();

    Bundle notificationMap = new Bundle();
    Bundle dataMap = new Bundle();

    // Cross platform notification properties
    String body = getNotificationBody(notification);
    if (body != null) {
      notificationMap.putString("body", body);
    }
    if (message.getData() != null) {
      for (Map.Entry<String, String> e : message.getData().entrySet()) {
        dataMap.putString(e.getKey(), e.getValue());
      }
    }
    notificationMap.putBundle("data", dataMap);
    if (message.getMessageId() != null) {
      notificationMap.putString("notificationId", message.getMessageId());
    }
    if (notification.getSound() != null) {
      notificationMap.putString("sound", notification.getSound());
    }
    String title = getNotificationTitle(notification);
    if (title != null) {
      notificationMap.putString("title", title);
    }

    // Android specific notification properties
    Bundle androidMap = new Bundle();
    if (notification.getClickAction() != null) {
      androidMap.putString("clickAction", notification.getClickAction());
    }
    if (notification.getColor() != null) {
      androidMap.putString("color", notification.getColor());
    }
    if (notification.getIcon() != null) {
      Bundle iconMap = new Bundle();
      iconMap.putString("icon", notification.getIcon());
      androidMap.putBundle("smallIcon", iconMap);
    }
    if (notification.getTag() != null) {
      androidMap.putString("group", notification.getTag());
      androidMap.putString("tag", notification.getTag());
    }
    notificationMap.putBundle("android", androidMap);

    return notificationMap;
  }

  private @Nullable String getNotificationBody(RemoteMessage.Notification notification) {
    String body = notification.getBody();
    String bodyLocKey = notification.getBodyLocalizationKey();
    if (bodyLocKey != null) {
      String[] bodyLocArgs = notification.getBodyLocalizationArgs();
      Context ctx = getApplicationContext();
      int resId = getResId(ctx, bodyLocKey);
      return ctx.getResources().getString(resId, (Object[]) bodyLocArgs);
    } else {
      return body;
    }
  }

  private @Nullable String getNotificationTitle(RemoteMessage.Notification notification) {
    String title = notification.getTitle();
    String titleLocKey = notification.getTitleLocalizationKey();
    if (titleLocKey != null) {
      String[] titleLocArgs = notification.getTitleLocalizationArgs();
      Context ctx = getApplicationContext();
      int resId = getResId(ctx, titleLocKey);
      return ctx.getResources().getString(resId, (Object[]) titleLocArgs);
    } else {
      return title;
    }
  }

  private class RemoteNotificationReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
      Log.d(TAG, "Received new remote notification");

      RemoteMessage message = intent.getParcelableExtra("notification");
      Bundle messageMap = parseRemoteMessage(message);

      Utils.sendEvent(mModuleRegistry.get(), "Expo.Firebase.notifications_notification_received", messageMap);
    }
  }

  private class ScheduledNotificationReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
      Log.d(TAG, "Received new scheduled notification");

      Bundle notification = intent.getBundleExtra("notification");

      Utils.sendEvent(mModuleRegistry.get(), "Expo.Firebase.notifications_notification_received", notification);
    }
  }
}
