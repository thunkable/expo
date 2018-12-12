// Copyright 2015-present 650 Industries. All rights reserved.

package abi31_0_0.expo.modules.sensors.modules;

import android.content.Context;
import android.hardware.SensorEvent;
import android.os.Bundle;

import abi31_0_0.expo.core.Promise;
import abi31_0_0.expo.core.interfaces.ExpoMethod;
import abi31_0_0.expo.interfaces.sensors.SensorService;
import abi31_0_0.expo.interfaces.sensors.services.MagnetometerService;

public class MagnetometerModule extends BaseSensorModule {
  public MagnetometerModule(Context reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "ExponentMagnetometer";
  }

  @Override
  public String getEventName() {
    return "magnetometerDidUpdate";
  }

  @Override
  protected SensorService getSensorService() {
    return getModuleRegistry().getModule(MagnetometerService.class);
  }

  protected Bundle eventToMap(SensorEvent sensorEvent) {
    Bundle map = new Bundle();
    map.putDouble("x", sensorEvent.values[0]);
    map.putDouble("y", sensorEvent.values[1]);
    map.putDouble("z", sensorEvent.values[2]);
    return map;
  }

  @ExpoMethod
  public void startObserving(Promise promise) {
    super.startObserving();
    promise.resolve(null);
  }

  @ExpoMethod
  public void stopObserving(Promise promise) {
    super.stopObserving();
    promise.resolve(null);
  }

  @ExpoMethod
  public void setUpdateInterval(int updateInterval, Promise promise) {
    super.setUpdateInterval(updateInterval);
    promise.resolve(null);
  }
}
