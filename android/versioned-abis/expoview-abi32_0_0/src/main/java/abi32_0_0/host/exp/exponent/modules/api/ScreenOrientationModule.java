package abi32_0_0.host.exp.exponent.modules.api;

import android.app.Activity;
import android.content.pm.ActivityInfo;

import abi32_0_0.com.facebook.react.bridge.JSApplicationIllegalArgumentException;
import abi32_0_0.com.facebook.react.bridge.LifecycleEventListener;
import abi32_0_0.com.facebook.react.bridge.Promise;
import abi32_0_0.com.facebook.react.bridge.ReactApplicationContext;
import abi32_0_0.com.facebook.react.bridge.ReactContextBaseJavaModule;
import abi32_0_0.com.facebook.react.bridge.ReactMethod;

import javax.annotation.Nullable;

public class ScreenOrientationModule extends ReactContextBaseJavaModule implements LifecycleEventListener {
  private @Nullable Integer mInitialOrientation = null;

  public ScreenOrientationModule(ReactApplicationContext reactContext) {
    super(reactContext);

    reactContext.addLifecycleEventListener(this);
  }

  @Override
  public String getName() {
    return "ExponentScreenOrientation";
  }

  @Override
  public void onHostResume() {
    Activity activity = getCurrentActivity();
    if (activity != null && mInitialOrientation == null) {
      mInitialOrientation = activity.getRequestedOrientation();
    }
  }

  @Override
  public void onHostPause() {

  }

  @Override
  public void onHostDestroy() {

  }

  @Override
  public void onCatalystInstanceDestroy() {
    super.onCatalystInstanceDestroy();

    Activity activity = getCurrentActivity();
    if (activity != null && mInitialOrientation != null) {
      activity.setRequestedOrientation(mInitialOrientation);
    }
  }

  @ReactMethod
  public void allowAsync(String orientation, Promise promise) {
    Activity activity = getCurrentActivity();
    if (activity == null) {
      return;
    }

    activity.setRequestedOrientation(convertToOrientationEnum(orientation));
    promise.resolve(null);
  }

  @ReactMethod
  public void doesSupportAsync(String orientation, Promise promise) {
    try {
      convertToOrientationEnum(orientation);
    } catch (JSApplicationIllegalArgumentException exception) {
      promise.reject(exception);
      return;
    }
    promise.resolve(true);
  }

  private int convertToOrientationEnum(String orientation) throws JSApplicationIllegalArgumentException {
    switch (orientation) {
      case "ALL":
        return ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR;
      case "ALL_BUT_UPSIDE_DOWN":
        return ActivityInfo.SCREEN_ORIENTATION_SENSOR;
      case "PORTRAIT":
        return ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT;
      case "PORTRAIT_UP":
        return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
      case "PORTRAIT_DOWN":
        return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
      case "LANDSCAPE":
        return ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE;
      case "LANDSCAPE_LEFT":
        return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
      case "LANDSCAPE_RIGHT":
        return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
      default:
        throw new JSApplicationIllegalArgumentException("Invalid screen orientation " + orientation);
    }
  }
}

