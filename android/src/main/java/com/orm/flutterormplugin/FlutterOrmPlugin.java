package com.orm.flutterormplugin;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.util.Log;

import com.common.luakit.LuaHelper;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import org.chromium.base.PathUtils;


/** FlutterOrmPlugin */
public class FlutterOrmPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    try {
      LuaHelper.startLuaKit(registrar.context());
      String toPath = PathUtils.getDataDirectory(registrar.context())+"/lua";
      File toFolder = new File(toPath);
      if (!toFolder.exists()){
          toFolder.mkdir();
      }
      copyFolderFromAssets(registrar,"packages/flutter_orm_plugin/lua",toPath);
    } catch (Exception e) {
      e.printStackTrace();
    }

  }

  private static void copyFolderFromAssets(Registrar registrar, String rootDirFullPath, String targetDirFullPath) {
    Log.d("copyfile", "copyFolderFromAssets " + "rootDirFullPath-" + rootDirFullPath + " targetDirFullPath-" + targetDirFullPath);
    try {
      AssetManager assetManager = registrar.context().getAssets();
      String key = registrar.lookupKeyForAsset(rootDirFullPath);
      String[] listFiles = assetManager.list(key);
      for (String string : listFiles) {
        Log.d("copyfile", "name-" + rootDirFullPath + "/" + string);
        if (isFileByName(string)) {
          copyFileFromAssets(registrar, rootDirFullPath + "/" + string, targetDirFullPath + "/" + string);
        } else {
          String childRootDirFullPath = rootDirFullPath + "/" + string;
          String childTargetDirFullPath = targetDirFullPath + "/" + string;
          File toFolder = new File(childTargetDirFullPath);
          if (toFolder.exists()){
              deleteDirection(toFolder);
          }
          new File(childTargetDirFullPath).mkdirs();
          copyFolderFromAssets(registrar, childRootDirFullPath, childTargetDirFullPath);
        }
      }
    } catch (IOException e) {
      Log.d("copyfile", "copyFolderFromAssets " + "IOException-" + e.getMessage());
      Log.d("copyfile", "copyFolderFromAssets " + "IOException-" + e.getLocalizedMessage());
      e.printStackTrace();
    }
  }

    private static boolean deleteDirection(File dir) {
        if (dir == null || !dir.exists() || dir.isFile()) {
            return false;
        }
        for (File file : dir.listFiles()) {
            if (file.isFile()) {
                file.delete();
            } else if (file.isDirectory()) {
                deleteDirection(file);// 递归
            }
        }
        dir.delete();
        return true;
    }

  private static void copyFileFromAssets(Registrar registrar, String assetsFilePath, String targetFileFullPath) {
    Log.d("copyfile", "copyFileFromAssets ");
    InputStream assestsFileImputStream;
    try {
      AssetManager assetManager = registrar.context().getAssets();
      String key = registrar.lookupKeyForAsset(assetsFilePath);
      assestsFileImputStream = assetManager.open(key);
      File toFile = new File(targetFileFullPath);
      if (toFile.exists()){
          toFile.delete();
      }
      FileOutputStream fos = new FileOutputStream(new File(targetFileFullPath));
      byte[] buffer = new byte[1024];
      int byteCount=0;
      while((byteCount=assestsFileImputStream.read(buffer))!=-1) {
        fos.write(buffer, 0, byteCount);
      }
      fos.flush();
      assestsFileImputStream.close();
      fos.close();
    } catch (IOException e) {
      Log.d("copyfile", "copyFileFromAssets " + "IOException-" + e.getMessage());
      e.printStackTrace();
    }
  }

  private static boolean isFileByName(String string) {
    if (string.contains(".")) {
      return true;
    }
    return false;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {

  }
}
