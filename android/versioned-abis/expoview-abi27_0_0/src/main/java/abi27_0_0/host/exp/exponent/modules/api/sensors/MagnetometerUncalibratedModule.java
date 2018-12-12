// Copyright 2015-present 650 Industries. All rights reserved.

package abi27_0_0.host.exp.exponent.modules.api.sensors;

import android.hardware.SensorEvent;

import abi27_0_0.com.facebook.react.bridge.Arguments;
import abi27_0_0.com.facebook.react.bridge.ReactApplicationContext;
import abi27_0_0.com.facebook.react.bridge.ReactMethod;
import abi27_0_0.com.facebook.react.bridge.WritableMap;

import host.exp.exponent.kernel.ExperienceId;
import host.exp.exponent.kernel.services.sensors.SubscribableSensorKernelService;

public class MagnetometerUncalibratedModule extends BaseSensorModule {
  public MagnetometerUncalibratedModule(ReactApplicationContext reactContext, ExperienceId experienceId) {
    super(reactContext, experienceId);
  }

  @Override
  public String getName() {
    return "ExponentMagnetometerUncalibrated";
  }

  @Override
  public String getEventName() {
    return "magnetometerUncalibratedDidUpdate";
  }

  @Override
  protected SubscribableSensorKernelService getKernelService() {
    return mKernelServiceRegistry.getMagnetometerUncalibratedKernelService();
  }

  protected WritableMap eventToMap(SensorEvent sensorEvent) {
    WritableMap map = Arguments.createMap();
    map.putDouble("x", sensorEvent.values[0]);
    map.putDouble("y", sensorEvent.values[1]);
    map.putDouble("z", sensorEvent.values[2]);
    return map;
  }

  @ReactMethod
  public void startObserving() {
    super.startObserving();
  }

  @ReactMethod
  public void stopObserving() {
    super.stopObserving();
  }

  @ReactMethod
  public void setUpdateInterval(int updateInterval) {
    super.setUpdateInterval(updateInterval);
  }
}
