// 添加必要的导入
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.widget.ListView;
import android.widget.Toast;
import java.util.ArrayList;

class SceneManager {
  private ArrayList<String> sceneNames = new ArrayList<String>();
  private int currentSceneIndex = 0;
  private String currentSceneName = "\u9ed8\u8ba4\u573a\u666f"; // "默认场景"
  private ArrayList<StarObject> stars;
  private FileManager fileManager;
  private Activity activity;
  
  public SceneManager(ArrayList<StarObject> stars, FileManager fileManager, Activity activity) {
    this.stars = stars;
    this.fileManager = fileManager;
    this.activity = activity;
  }
  
  // 初始化场景管理器
  public void initialize() {
    loadSceneList();
  }
  
  // 获取当前场景名称
  public String getCurrentSceneName() {
    return currentSceneName;
  }
  
  // 获取场景文件名
  public String getSceneFileName(String sceneName) {
    return "scene_" + sceneName + ".json";
  }
  
  // 加载场景列表 - 简化版，直接扫描目录
  public void loadSceneList() {
    // 清空当前列表
    sceneNames.clear();
    
    // 获取存储目录中的所有json文件
    java.io.File storageDir = activity.getExternalFilesDir(null);
    println("Loading scenes from directory: " + (storageDir != null ? storageDir.getAbsolutePath() : "null"));
    
    if (storageDir != null) {
      java.io.File[] files = storageDir.listFiles(new java.io.FilenameFilter() {
        public boolean accept(java.io.File dir, String name) {
          boolean isValid = name.toLowerCase().endsWith(".json") && name.startsWith("scene_");
          println("Found file: " + name + " - Valid scene file: " + isValid);
          return isValid;
        }
      });
      
      if (files != null && files.length > 0) {
        println("Found " + files.length + " scene files");
        for (java.io.File file : files) {
          // 从文件名中提取场景名称 (scene_NAME.json)
          String fileName = file.getName();
          String sceneName = fileName.substring(6, fileName.length() - 5); // 去掉"scene_"前缀和".json"后缀
          println("Adding scene: " + sceneName + " from file: " + fileName);
          sceneNames.add(sceneName);
        }
      } else {
        println("No scene files found");
      }
    } else {
      println("Storage directory is null");
    }
    
    // 如果没有场景，创建默认场景
    if (sceneNames.isEmpty()) {
      println("No scenes found, creating default scene");
      sceneNames.add("\u9ed8\u8ba4\u573a\u666f");  // "默认场景"
      currentSceneIndex = 0;
      currentSceneName = "\u9ed8\u8ba4\u573a\u666f";  // "默认场景"
      // 保存当前空场景
      fileManager.saveStars(getSceneFileName(currentSceneName));
    } else {
      // 加载第一个场景
      currentSceneIndex = 0;
      currentSceneName = sceneNames.get(0);
      println("Loading first scene: " + currentSceneName);
      fileManager.loadStars(getSceneFileName(currentSceneName));
    }
    
    // 打印所有加载的场景
    println("All loaded scenes:");
    for (String scene : sceneNames) {
      println(" - " + scene);
    }
  }
  
  // 切换到指定场景
  public void switchToScene(int sceneIndex) {
    if (sceneIndex >= 0 && sceneIndex < sceneNames.size()) {
      try {
        // 保存当前场景
        fileManager.saveStars(getSceneFileName(currentSceneName));
        
        // 切换到新场景
        currentSceneIndex = sceneIndex;
        currentSceneName = sceneNames.get(sceneIndex);
        
        // 加载新场景的星星
        stars.clear();
        fileManager.loadStars(getSceneFileName(currentSceneName));
      } catch (Exception e) {
        // 处理异常，防止应用崩溃
        println("Error switching scene: " + e.getMessage());
        e.printStackTrace();
        
        // 如果发生错误，尝试创建一个新的空场景文件
        try {
          stars.clear();
          fileManager.saveStars(getSceneFileName(currentSceneName));
          Toast.makeText(activity, "已创建空场景", Toast.LENGTH_SHORT).show();
        } catch (Exception ex) {
          println("Failed to create empty scene: " + ex.getMessage());
          ex.printStackTrace();
          Toast.makeText(activity, "场景切换失败", Toast.LENGTH_SHORT).show();
        }
      }
    }
  }
  
  // 创建新场景
  public void createNewScene(String sceneName) {
    if (sceneName != null && !sceneName.trim().isEmpty()) {
      // 保存当前场景
      fileManager.saveStars(getSceneFileName(currentSceneName));
      
      // 添加新场景到列表
      sceneNames.add(sceneName);
      currentSceneIndex = sceneNames.size() - 1;
      currentSceneName = sceneName;
      
      // 清空星星列表，创建新的空场景
      stars.clear();
      String fileName = getSceneFileName(currentSceneName);
      println("Creating new scene: " + currentSceneName + " with file name: " + fileName);
      fileManager.saveStars(fileName);
    }
  }
  
  // 删除场景
  public void deleteScene(int sceneIndex) {
    if (sceneNames.size() <= 1) {
      Toast.makeText(activity, "\u81f3\u5c11\u9700\u8981\u4fdd\u7559\u4e00\u4e2a\u573a\u666f", Toast.LENGTH_SHORT).show();  // "至少需要保留一个场景"
      return;
    }
    
    String sceneToDelete = sceneNames.get(sceneIndex);
    
    // 删除场景文件
    try {
      java.io.File storageDir = activity.getExternalFilesDir(null);
      java.io.File sceneFile = new java.io.File(storageDir, getSceneFileName(sceneToDelete));
      if (sceneFile.exists()) {
        boolean deleted = sceneFile.delete();
        println("Deleting scene file: " + sceneFile.getAbsolutePath() + " - Success: " + deleted);
      }
    } catch (Exception e) {
      println("Error deleting scene file: " + e.getMessage());
    }
    
    // 从列表中移除场景
    sceneNames.remove(sceneIndex);
    
    // 如果删除的是当前场景，切换到第一个场景
    if (sceneIndex == currentSceneIndex) {
      currentSceneIndex = 0;
      currentSceneName = sceneNames.get(0);
      stars.clear();
      fileManager.loadStars(getSceneFileName(currentSceneName));
    } 
    // 如果删除的场景索引小于当前场景索引，需要调整当前场景索引
    else if (sceneIndex < currentSceneIndex) {
      currentSceneIndex--;
    }
    
    Toast.makeText(activity, "\u573a\u666f '" + sceneToDelete + "' \u5df2\u5220\u9664", Toast.LENGTH_SHORT).show();  // "场景 '...' 已删除"
  }
  
  // 显示场景选择对话框
  public void showSceneSelector() {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u9009\u62e9\u573a\u666f");  // "选择场景"
        
        // 创建场景列表
        final String[] sceneArray = new String[sceneNames.size()];
        for (int i = 0; i < sceneNames.size(); i++) {
          sceneArray[i] = sceneNames.get(i);
        }
        
        // 设置当前选中的场景
        builder.setSingleChoiceItems(sceneArray, currentSceneIndex, new android.content.DialogInterface.OnClickListener() {
          public void onClick(android.content.DialogInterface dialog, int which) {
            // 切换到选中的场景
            switchToScene(which);
            dialog.dismiss();
          }
        });
        
        // 添加"新建场景"按钮
        builder.setPositiveButton("\u65b0\u5efa\u573a\u666f", new android.content.DialogInterface.OnClickListener() {  // "新建场景"
          public void onClick(android.content.DialogInterface dialog, int which) {
            showNewSceneDialog();
          }
        });
        
        // 添加"重命名"按钮
        builder.setNeutralButton("\u91cd\u547d\u540d", new android.content.DialogInterface.OnClickListener() {  // "重命名"
          public void onClick(android.content.DialogInterface dialog, int which) {
            showRenameSceneDialog();
          }
        });
        
        // 添加"删除场景"按钮
        builder.setNegativeButton("\u5220\u9664\u573a\u666f", new android.content.DialogInterface.OnClickListener() {  // "删除场景"
          public void onClick(android.content.DialogInterface dialog, int which) {
            showDeleteSceneDialog();
          }
        });
        
        builder.show();
      }
    });
  }
  
  // 显示新建场景对话框
  public void showNewSceneDialog() {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u65b0\u5efa\u573a\u666f");  // "新建场景"
        
        // 添加输入框
        final android.widget.EditText input = new android.widget.EditText(activity);
        input.setHint("\u8f93\u5165\u573a\u666f\u540d\u79f0");  // "输入场景名称"
        builder.setView(input);
        
        // 添加"确定"按钮
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() {  // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            String sceneName = input.getText().toString().trim();
            if (!sceneName.isEmpty()) {
              createNewScene(sceneName);
            }
          }
        });
        
        // 添加"取消"按钮
        builder.setNegativeButton("\u53d6\u6d88", new android.content.DialogInterface.OnClickListener() {  // "取消"
          public void onClick(android.content.DialogInterface dialog, int which) {
            dialog.dismiss();
          }
        });
        
        builder.show();
      }
    });
  }
  
  // 显示删除场景对话框
  public void showDeleteSceneDialog() {
    // 如果只有一个场景，不允许删除
    if (sceneNames.size() <= 1) {
      Toast.makeText(activity, "\u81f3\u5c11\u9700\u8981\u4fdd\u7559\u4e00\u4e2a\u573a\u666f", Toast.LENGTH_SHORT).show();  // "至少需要保留一个场景"
      return;
    }
    
    activity.runOnUiThread(new Runnable() {
      public void run() {
        // 创建对话框
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u5220\u9664\u573a\u666f");  // "删除场景"
        
        // 创建场景列表
        final String[] sceneArray = new String[sceneNames.size()];
        for (int i = 0; i < sceneNames.size(); i++) {
          sceneArray[i] = sceneNames.get(i);
        }
        
        // 设置单选列表
        builder.setSingleChoiceItems(sceneArray, currentSceneIndex, null);
        
        // 添加"删除"按钮
        builder.setPositiveButton("\u5220\u9664", new android.content.DialogInterface.OnClickListener() {  // "删除"
          public void onClick(android.content.DialogInterface dialog, int id) {
            // 获取选中的场景索引
            ListView listView = ((AlertDialog)dialog).getListView();
            int selectedIndex = listView.getCheckedItemPosition();
            
            if (selectedIndex >= 0 && selectedIndex < sceneNames.size()) {
              deleteScene(selectedIndex);
            }
          }
        });
        
        // 添加"取消"按钮
        builder.setNegativeButton("\u53d6\u6d88", new android.content.DialogInterface.OnClickListener() {  // "取消"
          public void onClick(android.content.DialogInterface dialog, int id) {
            dialog.cancel();
          }
        });
        
        // 显示对话框
        builder.show();
      }
    });
  }
  
  // 显示重命名场景对话框
  public void showRenameSceneDialog() {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        // 创建对话框
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u9009\u62e9\u8981\u91cd\u547d\u540d\u7684\u573a\u666f");  // "选择要重命名的场景"
        
        // 创建场景列表
        final String[] sceneArray = new String[sceneNames.size()];
        for (int i = 0; i < sceneNames.size(); i++) {
          sceneArray[i] = sceneNames.get(i);
        }
        
        // 设置单选列表
        builder.setSingleChoiceItems(sceneArray, currentSceneIndex, null);
        
        // 添加"确定"按钮
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() {  // "确定"
          public void onClick(android.content.DialogInterface dialog, int id) {
            // 获取选中的场景索引
            ListView listView = ((AlertDialog)dialog).getListView();
            int selectedIndex = listView.getCheckedItemPosition();
            
            if (selectedIndex >= 0 && selectedIndex < sceneNames.size()) {
              // 显示重命名输入对话框
              showRenameInputDialog(selectedIndex);
            }
          }
        });
        
        // 添加"取消"按钮
        builder.setNegativeButton("\u53d6\u6d88", new android.content.DialogInterface.OnClickListener() {  // "取消"
          public void onClick(android.content.DialogInterface dialog, int id) {
            dialog.cancel();
          }
        });
        
        // 显示对话框
        builder.show();
      }
    });
  }
  
  // 显示重命名输入对话框
  private void showRenameInputDialog(final int sceneIndex) {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u91cd\u547d\u540d\u573a\u666f");  // "重命名场景"
        
        // 添加输入框
        final android.widget.EditText input = new android.widget.EditText(activity);
        input.setText(sceneNames.get(sceneIndex));
        builder.setView(input);
        
        // 添加"确定"按钮
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() {  // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            String newName = input.getText().toString().trim();
            if (!newName.isEmpty() && !newName.equals(sceneNames.get(sceneIndex))) {
              renameScene(sceneIndex, newName);
            }
          }
        });
        
        // 添加"取消"按钮
        builder.setNegativeButton("\u53d6\u6d88", new android.content.DialogInterface.OnClickListener() {  // "取消"
          public void onClick(android.content.DialogInterface dialog, int which) {
            dialog.dismiss();
          }
        });
        
        builder.show();
      }
    });
  }
  
  // 重命名场景
  public void renameScene(int sceneIndex, String newName) {
    if (sceneIndex < 0 || sceneIndex >= sceneNames.size() || newName == null || newName.trim().isEmpty()) {
      return;
    }
    
    // 检查新名称是否已存在
    for (int i = 0; i < sceneNames.size(); i++) {
      if (i != sceneIndex && sceneNames.get(i).equals(newName)) {
        Toast.makeText(activity, "\u573a\u666f\u540d\u79f0\u5df2\u5b58\u5728", Toast.LENGTH_SHORT).show();  // "场景名称已存在"
        return;
      }
    }
    
    String oldName = sceneNames.get(sceneIndex);
    String oldFileName = getSceneFileName(oldName);
    String newFileName = getSceneFileName(newName);
    
    try {
      // 保存当前场景（如果正在编辑的是要重命名的场景）
      if (currentSceneIndex == sceneIndex) {
        fileManager.saveStars(oldFileName);
      }
      
      // 重命名文件
      java.io.File storageDir = activity.getExternalFilesDir(null);
      java.io.File oldFile = new java.io.File(storageDir, oldFileName);
      java.io.File newFile = new java.io.File(storageDir, newFileName);
      
      if (oldFile.exists()) {
        boolean success = oldFile.renameTo(newFile);
        if (success) {
          // 更新场景名称
          sceneNames.set(sceneIndex, newName);
          
          // 如果重命名的是当前场景，更新当前场景名称
          if (currentSceneIndex == sceneIndex) {
            currentSceneName = newName;
          }
          
          Toast.makeText(activity, "\u573a\u666f\u5df2\u91cd\u547d\u540d", Toast.LENGTH_SHORT).show();  // "场景已重命名"
          println("Scene renamed from '" + oldName + "' to '" + newName + "'");
        } else {
          Toast.makeText(activity, "\u91cd\u547d\u540d\u5931\u8d25", Toast.LENGTH_SHORT).show();  // "重命名失败"
          println("Failed to rename scene file from '" + oldFileName + "' to '" + newFileName + "'");
        }
      } else {
        Toast.makeText(activity, "\u573a\u666f\u6587\u4ef6\u4e0d\u5b58\u5728", Toast.LENGTH_SHORT).show();  // "场景文件不存在"
        println("Scene file does not exist: " + oldFileName);
      }
    } catch (Exception e) {
      Toast.makeText(activity, "\u91cd\u547d\u540d\u65f6\u51fa\u9519", Toast.LENGTH_SHORT).show();  // "重命名时出错"
      println("Error renaming scene: " + e.getMessage());
      e.printStackTrace();
    }
  }
} 