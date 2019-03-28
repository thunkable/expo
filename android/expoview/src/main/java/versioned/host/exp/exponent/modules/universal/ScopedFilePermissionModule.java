package versioned.host.exp.exponent.modules.universal;

import android.content.Context;

import java.io.File;
import java.io.IOException;
import java.util.EnumSet;

import expo.core.ModuleRegistry;
import expo.core.interfaces.ModuleRegistryConsumer;
import expo.interfaces.constants.ConstantsInterface;
import expo.modules.filesystem.FilePermissionModule;
import expo.interfaces.filesystem.Permission;
import host.exp.exponent.utils.ScopedContext;

public class ScopedFilePermissionModule extends FilePermissionModule implements ModuleRegistryConsumer {
  private ScopedContext mScopedContext;
  private ModuleRegistry mModuleRegistry;

  public ScopedFilePermissionModule(ScopedContext scopedContext) {
    mScopedContext = scopedContext;
  }

  @Override
  protected EnumSet<Permission> getExternalPathPermissions(String path) {
    try {
      // In scoped context we do not allow access to Expo Client's directory,
      // however accessing other directories is ok as far as we're concerned.
      Context context = mScopedContext.getContext();
      String dataDirCanonicalPath = new File(context.getApplicationInfo().dataDir).getCanonicalPath();
      String canonicalPath = new File(path).getCanonicalPath();
      boolean isInDataDir = canonicalPath.startsWith(dataDirCanonicalPath + "/");
      isInDataDir |= canonicalPath.equals(dataDirCanonicalPath);
      if (shouldForbidAccessToDataDirectory() && isInDataDir) {
        return EnumSet.noneOf(Permission.class);
      }
    } catch (IOException e) {
      // Something's not right, let's be cautious.
      return EnumSet.noneOf(Permission.class);
    }
    return super.getExternalPathPermissions(path);
  }

  private boolean shouldForbidAccessToDataDirectory() {
    ConstantsInterface constantsModule = mModuleRegistry.getModule(ConstantsInterface.class);
    // If there's no constants module, or app ownership isn't "expo", we're not in Expo Client.
    return constantsModule != null && "expo".equals(constantsModule.getAppOwnership());
  }

  @Override
  public void setModuleRegistry(ModuleRegistry moduleRegistry) {
    mModuleRegistry = moduleRegistry;
  }
}
