package abi32_0_0.expo.modules.sensors;

import android.content.Context;

import java.util.Arrays;
import java.util.List;

import abi32_0_0.expo.core.BasePackage;
import abi32_0_0.expo.core.ExportedModule;
import abi32_0_0.expo.core.interfaces.InternalModule;
import abi32_0_0.expo.modules.sensors.modules.AccelerometerModule;
import abi32_0_0.expo.modules.sensors.modules.DeviceMotionModule;
import abi32_0_0.expo.modules.sensors.modules.GyroscopeModule;
import abi32_0_0.expo.modules.sensors.modules.MagnetometerModule;
import abi32_0_0.expo.modules.sensors.modules.MagnetometerUncalibratedModule;
import abi32_0_0.expo.modules.sensors.modules.PedometerModule;
import abi32_0_0.expo.modules.sensors.services.AccelerometerService;
import abi32_0_0.expo.modules.sensors.services.GravitySensorService;
import abi32_0_0.expo.modules.sensors.services.GyroscopeService;
import abi32_0_0.expo.modules.sensors.services.LinearAccelerationSensorService;
import abi32_0_0.expo.modules.sensors.services.MagnetometerService;
import abi32_0_0.expo.modules.sensors.services.MagnetometerUncalibratedService;
import abi32_0_0.expo.modules.sensors.services.PedometerService;
import abi32_0_0.expo.modules.sensors.services.RotationVectorSensorService;

public class SensorsPackage extends BasePackage {

  @Override
  public List<InternalModule> createInternalModules(Context context) {
    return Arrays.<InternalModule>asList(
            new AccelerometerService(context),
            new GravitySensorService(context),
            new GyroscopeService(context),
            new LinearAccelerationSensorService(context),
            new MagnetometerService(context),
            new MagnetometerUncalibratedService(context),
            new RotationVectorSensorService(context),
            new PedometerService(context)
    );
  }

  @Override
  public List<ExportedModule> createExportedModules(Context context) {
    return Arrays.<ExportedModule>asList(
            new AccelerometerModule(context),
            new GyroscopeModule(context),
            new DeviceMotionModule(context),
            new MagnetometerModule(context),
            new MagnetometerUncalibratedModule(context),
            new PedometerModule(context)
    );
  }
}
