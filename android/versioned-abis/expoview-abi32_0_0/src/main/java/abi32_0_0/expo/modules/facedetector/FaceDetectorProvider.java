package abi32_0_0.expo.modules.facedetector;

import android.content.Context;

import java.util.Collections;
import java.util.List;

import abi32_0_0.expo.core.interfaces.InternalModule;
import abi32_0_0.expo.interfaces.facedetector.FaceDetector;

public class FaceDetectorProvider implements abi32_0_0.expo.interfaces.facedetector.FaceDetectorProvider, InternalModule {
  @Override
  public List<Class> getExportedInterfaces() {
    return Collections.singletonList((Class) abi32_0_0.expo.interfaces.facedetector.FaceDetectorProvider.class);
  }

  public FaceDetector createFaceDetectorWithContext(Context context) {
    return new ExpoFaceDetector(context);
  }
}
