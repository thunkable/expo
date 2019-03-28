
package abi32_0_0.expo.modules.print;

import android.content.Context;

import java.util.Collections;
import java.util.List;

import abi32_0_0.expo.core.BasePackage;
import abi32_0_0.expo.core.ExportedModule;
import abi32_0_0.expo.core.ViewManager;

public class PrintPackage extends BasePackage {
  @Override
  public List<ExportedModule> createExportedModules(Context context) {
    return Collections.singletonList((ExportedModule) new PrintModule(context));
  }
}
