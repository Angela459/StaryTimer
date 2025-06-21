class FileManager {
  private String currentFileName = "stars.json";  // 默认文件名
  private String taskFileName = "tasks.json";     // 任务文件名
  private ArrayList<StarObject> stars;
  private PApplet parent;  // 添加对主应用的引用
  private Activity activity;  // 添加Activity引用
  private boolean isDirty = false;  // 添加一个标记，表示数据是否被修改
  
  FileManager(ArrayList<StarObject> stars, PApplet parent) {
    this.stars = stars;
    this.parent = parent;  // 直接接收PApplet实例
    this.activity = parent.getActivity();  // 获取Activity引用
  }
  
  // 获取完整的文件路径
  private String getFullPath(String fileName) {
    try {
      // 在Android上使用外部存储目录
      java.io.File storageDir = activity.getExternalFilesDir(null);
      
      // 确保目录存在
      if (!storageDir.exists()) {
        boolean created = storageDir.mkdirs();
        println("Storage directory created: " + created);
      }
      
      java.io.File file = new java.io.File(storageDir, fileName);
      String fullPath = file.getAbsolutePath();
      println("Full path for " + fileName + ": " + fullPath);
      return fullPath;
    } catch (Exception e) {
      println("Error getting full path: " + e.getMessage());
      // 回退到默认的dataPath
      return parent.dataPath(fileName);
    }
  }
  
  // 加载星星，使用默认文件名
  void loadStars() {
    loadStars(currentFileName);
  }
  
  // 加载星星，使用指定文件名
  void loadStars(String fileName) {
    currentFileName = fileName;
    try {
      // 使用完整路径加载文件
      String fullPath = getFullPath(fileName);
      println("Loading stars from: " + fullPath);
      
      java.io.File file = new java.io.File(fullPath);
      if (!file.exists()) {
        println("File does not exist: " + fullPath);
        // 如果文件不存在，创建一个空文件
        createEmptyStarsFile(fileName);
        return;
      }
      
      // 检查文件是否可读
      if (!file.canRead()) {
        println("File is not readable: " + fullPath);
        return;
      }
      
      // 检查文件大小
      if (file.length() == 0) {
        println("File is empty: " + fullPath);
        return;
      }
      
      String[] lines = null;
      try {
        lines = loadStrings(fullPath);
      } catch (Exception e) {
        println("Error loading file: " + e.getMessage());
        e.printStackTrace();
        // 如果加载失败，创建一个新的空文件
        createEmptyStarsFile(fileName);
        return;
      }
      
      println("Loaded lines: " + (lines != null ? lines.length : "null"));
      
      if (lines != null && lines.length > 0) {
        String jsonStr = join(lines, "");
        println("JSON string: " + jsonStr);
        
        // 检查JSON字符串是否为空或无效
        if (jsonStr == null || jsonStr.trim().isEmpty() || jsonStr.equals("null")) {
          println("JSON string is empty or null");
          return;
        }
        
        try {
          JSONArray savedStars = parseJSONArray(jsonStr);
          
          // 清空当前星星列表
          stars.clear();
          
          for (int i = 0; i < savedStars.size(); i++) {
            JSONObject starData = savedStars.getJSONObject(i);
            StarObject star = ((StaryTimerAndroid)parent).starManager.createStar(
              starData.getFloat("posX"),
              starData.getFloat("posY"),
              starData.getFloat("size")
            );
            
            // 从JSON加载任务相关信息
            star.fromJSON(starData);
            
            stars.add(star);
          }
          println("Loaded " + stars.size() + " stars from " + fullPath);
        } catch (Exception e) {
          println("Error parsing JSON: " + e.getMessage());
          e.printStackTrace();
          
          // 如果JSON解析失败，尝试创建一个新的空文件
          println("Creating new empty file after JSON parse error");
          createEmptyStarsFile(fileName);
        }
      }
    } catch(Exception e) {
      println("Error loading stars from " + fileName + ": " + e.getMessage());
      e.printStackTrace();  // 打印详细错误信息
      
      // 处理任何未捕获的异常，确保应用不会崩溃
      try {
        // 重置为空星星列表
        stars.clear();
        createEmptyStarsFile(fileName);
      } catch (Exception ex) {
        println("Failed to recover from error: " + ex.getMessage());
      }
    }
  }
  
  // 创建一个空的星星文件，避免在loadStars中直接调用saveStars导致的递归
  private void createEmptyStarsFile(String fileName) {
    try {
      java.io.File storageDir = activity.getExternalFilesDir(null);
      
      // 确保目录存在
      if (!storageDir.exists()) {
        boolean created = storageDir.mkdirs();
        println("Storage directory created: " + created);
      }
      
      String fullPath = getFullPath(fileName);
      println("Creating empty stars file: " + fullPath);
      
      // 创建一个空的JSON数组
      JSONArray emptyArray = new JSONArray();
      
      // 直接使用Java IO写入文件
      java.io.FileWriter writer = new java.io.FileWriter(fullPath);
      writer.write(emptyArray.toString());
      writer.close();
      
      println("Empty stars file created successfully");
      
    } catch (Exception e) {
      println("Error creating empty stars file: " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  // 保存星星，使用默认文件名
  void saveStars() {
    saveStars(currentFileName);
  }
  
  // 保存星星，使用指定文件名
  void saveStars(String fileName) {
    currentFileName = fileName;
    if (!isDirty && fileName.equals(currentFileName)) {
      // 只有在数据被修改或者是不同文件名时才需要保存
      // 但确保目录和文件存在
      try {
        java.io.File storageDir = activity.getExternalFilesDir(null);
        if (!storageDir.exists()) {
          storageDir.mkdirs();
        }
        
        String fullPath = getFullPath(fileName);
        java.io.File file = new java.io.File(fullPath);
        if (!file.exists()) {
          // 如果文件不存在，我们需要创建它，即使数据没有被修改
          isDirty = true;
        }
      } catch (Exception e) {
        println("Error checking file: " + e.getMessage());
      }
      
      if (!isDirty) return;  // 如果仍然不需要保存，则返回
    }
    
    try {
      java.io.File storageDir = activity.getExternalFilesDir(null);
      
      // 确保目录存在
      if (!storageDir.exists()) {
        boolean created = storageDir.mkdirs();
        println("Storage directory created: " + created);
      }
      
      println("Saving to directory: " + storageDir.getAbsolutePath());
      JSONArray savedStars = new JSONArray();
      
      // 将所有星星转换为JSON并添加到数组
      for (StarObject star : stars) {
        try {
          savedStars.append(star.toJSON());
        } catch (Exception e) {
          println("Error converting star to JSON: " + e.getMessage());
          // 继续处理其他星星
        }
      }
      
      // 使用完整路径保存文件
      String fullPath = getFullPath(fileName);
      println("Saving " + stars.size() + " stars to: " + fullPath);
      
      // 保存到文件
      try {
        saveStrings(fullPath, new String[] { savedStars.toString() });
      } catch (Exception e) {
        println("Error saving strings to file: " + e.getMessage());
        e.printStackTrace();
        
        // 尝试使用Java IO直接保存
        try {
          java.io.FileWriter writer = new java.io.FileWriter(fullPath);
          writer.write(savedStars.toString());
          writer.close();
          println("Saved using FileWriter");
        } catch (Exception ex) {
          println("Failed to save using FileWriter: " + ex.getMessage());
          throw ex; // 重新抛出异常
        }
      }
      
      // 验证文件是否已创建
      java.io.File savedFile = new java.io.File(fullPath);
      if (savedFile.exists()) {
        println("File saved successfully, size: " + savedFile.length() + " bytes");
      } else {
        println("Warning: File was not created");
      }
      
      isDirty = false;  // 重置修改标记
    } catch(Exception e) {
      println("Error saving stars to " + fileName + ": " + e.getMessage());
      e.printStackTrace();  // 打印详细错误信息
      
      // 错误发生时的恢复处理，简单显示错误信息，防止应用崩溃
      activity.runOnUiThread(new Runnable() {
        public void run() {
          Toast.makeText(activity, "保存文件失败", Toast.LENGTH_SHORT).show();
        }
      });
    }
  }
  
  void saveStar(StarObject star) {
    try {
      JSONArray savedStars;
      String fullPath = getFullPath(currentFileName);
      String[] lines = loadStrings(fullPath);
      
      if (lines != null && lines.length > 0) {
        String jsonStr = join(lines, "");
        savedStars = parseJSONArray(jsonStr);
      } else {
        savedStars = new JSONArray();
      }
      
      savedStars.append(star.toJSON());
      saveStrings(fullPath, new String[] { savedStars.toString() });
      
    } catch(Exception e) {
      println("Error saving star: " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  void removeStar(int index) {
    if (index >= 0 && index < stars.size()) {
      stars.remove(index);
      isDirty = true;  // 标记数据已修改
      saveStars();     // 立即保存到文件
    }
  }
  
  void updateStarPosition(int index, float x, float y) {
    try {
      // 首先更新内存中的星星位置
      if (index >= 0 && index < stars.size()) {
        StarObject star = stars.get(index);
        star.setX(x);
        star.setY(y);
        
        // 保存所有星星到文件
        isDirty = true;  // 标记数据已修改
        saveStars();
        println("Updated star position and saved to file");
      } else {
        println("Error: Invalid star index: " + index);
      }
    } catch(Exception e) {
      println("Error updating star position: " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  // 添加新星星并保存
  void addStar(StarObject newStar) {
    stars.add(newStar);
    isDirty = true;  // 标记数据已修改
    saveStars();     // 立即保存到文件
  }
  
  // 显示删除确认对话框
  void showDeleteConfirmDialog(final int starIndex) {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u5220\u9664\u661f\u661f");  // "删除星星"
        builder.setMessage("\u4f60\u786e\u5b9a\u8981\u5220\u9664\u8fd9\u4e2a\u661f\u661f\u5417\uff1f");  // "你确定要删除这个星星吗？"
        
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() {  // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            removeStar(starIndex);
          }
        });
        
        builder.setNegativeButton("\u53d6\u6d88", new android.content.DialogInterface.OnClickListener() {  // "取消"
          public void onClick(android.content.DialogInterface dialog, int which) {
            dialog.cancel();
          }
        });
        
        builder.show();
      }
    });
  }
  
  // 显示星星信息对话框
  void showStarInfoDialog(final int starIndex) {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u661f\u661f\u4fe1\u606f");  // "星星信息"
        
        // 获取星星信息
        StarObject star = stars.get(starIndex);
        String taskName = star.getTaskName() != null ? star.getTaskName() : "\u672a\u547d\u540d\u4efb\u52a1";  // "未命名任务"
        String duration = formatDuration(star.getDuration());  // 格式化时长
        String date = star.getDate() != null ? star.getDate() : "\u672a\u77e5\u65e5\u671f";  // "未知日期"
        
        // 构建信息文本
        StringBuilder message = new StringBuilder();
        message.append("\u4efb\u52a1\u540d\u79f0\uff1a").append(taskName).append("\n\n");  // "任务名称："
        message.append("\u8ba1\u65f6\u65f6\u957f\uff1a").append(duration).append("\n\n");  // "计时时长："
        message.append("\u5b8c\u6210\u65e5\u671f\uff1a").append(date);  // "完成日期："
        
        builder.setMessage(message.toString());
        
        // 添加删除按钮
        builder.setNegativeButton("\u5220\u9664", new android.content.DialogInterface.OnClickListener() {  // "删除"
          public void onClick(android.content.DialogInterface dialog, int which) {
            // 显示确认删除对话框
            showDeleteConfirmDialog(starIndex);
          }
        });
        
        // 添加关闭按钮
        builder.setPositiveButton("\u5173\u95ed", new android.content.DialogInterface.OnClickListener() {  // "关闭"
          public void onClick(android.content.DialogInterface dialog, int which) {
            dialog.dismiss();
          }
        });
        
        builder.show();
      }
    });
  }
  
  // 格式化时长的方法，正确处理毫秒转换
  private String formatDuration(long durationMillis) {
    // 将毫秒转换为小时、分钟和秒
    long totalSeconds = durationMillis / 1000;
    long hours = totalSeconds / 3600;
    long minutes = (totalSeconds % 3600) / 60;
    long seconds = totalSeconds % 60;
    
    // 格式化为"X时X分X秒"
    return String.format("%d\u65f6%d\u5206%d\u79d2", hours, minutes, seconds);  // X时X分X秒
  }
  
  // 获取当前文件名
  String getCurrentFileName() {
    return currentFileName;
  }
  
  // 设置当前文件名
  void setCurrentFileName(String fileName) {
    this.currentFileName = fileName;
  }
  
  // 保存任务列表到JSON文件
  void saveTasks(ArrayList<Task> tasks) {
    try {
      java.io.File storageDir = activity.getExternalFilesDir(null);
      
      // 确保目录存在
      if (!storageDir.exists()) {
        boolean created = storageDir.mkdirs();
        println("Storage directory created: " + created);
      }
      
      println("Saving tasks to directory: " + storageDir.getAbsolutePath());
      JSONArray savedTasks = new JSONArray();
      
      // 将所有任务转换为JSON并添加到数组
      for (Task task : tasks) {
        JSONObject taskJson = new JSONObject();
        taskJson.setString("name", task.getName());
        taskJson.setLong("duration", task.getTotalDuration());
        taskJson.setInt("completedCount", task.getCompletedCount());
        
        // 保存提醒日期（如果有）
        if (task.hasReminder()) {
          taskJson.setLong("reminderDate", task.getReminderDate().getTime());
        } else {
          taskJson.setLong("reminderDate", -1);
        }
        
        savedTasks.append(taskJson);
      }
      
      // 使用完整路径保存文件
      String fullPath = getFullPath(taskFileName);
      println("Saving " + tasks.size() + " tasks to: " + fullPath);
      
      // 保存到文件
      saveStrings(fullPath, new String[] { savedTasks.toString() });
      
      // 验证文件是否已创建
      java.io.File savedFile = new java.io.File(fullPath);
      if (savedFile.exists()) {
        println("Tasks file saved successfully, size: " + savedFile.length() + " bytes");
      } else {
        println("Warning: Tasks file was not created");
      }
      
    } catch(Exception e) {
      println("Error saving tasks to " + taskFileName + ": " + e.getMessage());
      e.printStackTrace();  // 打印详细错误信息
    }
  }
  
  // 从JSON文件加载任务列表
  ArrayList<Task> loadTasks() {
    ArrayList<Task> tasks = new ArrayList<Task>();
    
    try {
      // 使用完整路径加载文件
      String fullPath = getFullPath(taskFileName);
      println("Loading tasks from: " + fullPath);
      
      java.io.File file = new java.io.File(fullPath);
      if (!file.exists()) {
        println("Tasks file does not exist: " + fullPath);
        // 如果文件不存在，返回空列表
        return tasks;
      }
      
      // 检查文件是否可读
      if (!file.canRead()) {
        println("Tasks file is not readable: " + fullPath);
        return tasks;
      }
      
      // 检查文件大小
      if (file.length() == 0) {
        println("Tasks file is empty: " + fullPath);
        return tasks;
      }
      
      String[] lines = loadStrings(fullPath);
      println("Loaded lines from tasks file: " + (lines != null ? lines.length : "null"));
      
      if (lines != null && lines.length > 0) {
        String jsonStr = join(lines, "");
        println("Tasks JSON string: " + jsonStr);
        
        // 检查JSON字符串是否为空或无效
        if (jsonStr == null || jsonStr.trim().isEmpty() || jsonStr.equals("null")) {
          println("Tasks JSON string is empty or null");
          return tasks;
        }
        
        try {
          JSONArray savedTasks = parseJSONArray(jsonStr);
          
          for (int i = 0; i < savedTasks.size(); i++) {
            JSONObject taskData = savedTasks.getJSONObject(i);
            String name = taskData.getString("name", "");
            long duration = taskData.getLong("duration", 0);
            int completedCount = taskData.getInt("completedCount", 0);
            long reminderMillis = taskData.getLong("reminderDate", -1);
            
            if (!name.isEmpty()) {
              Task task = new Task(name, duration);
              task.setCompletedCount(completedCount);
              
              // 如果有提醒日期，设置它
              if (reminderMillis != -1) {
                task.setReminderDate(new java.util.Date(reminderMillis));
              }
              
              tasks.add(task);
            }
          }
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    } catch(Exception e) {
      e.printStackTrace();  // 打印详细错误信息
    }
    
    return tasks;
  }
  
  // 添加单个任务到JSON文件
  void addTask(Task task) {
    try {
      // 先加载现有任务
      ArrayList<Task> tasks = loadTasks();
      
      // 添加新任务
      tasks.add(task);
      
      // 保存所有任务
      saveTasks(tasks);
      
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
  
  // 删除任务
  void removeTask(int index) {
    try {
      // 先加载现有任务
      ArrayList<Task> tasks = loadTasks();
      
      // 检查索引是否有效
      if (index >= 0 && index < tasks.size()) {
        // 删除指定任务
        tasks.remove(index);
        
        // 保存更新后的任务列表
        saveTasks(tasks);
      } else {
        println("Error: Invalid task index: " + index);
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
  
  // 更新任务
  void updateTask(int index, Task updatedTask) {
    try {
      // 先加载现有任务
      ArrayList<Task> tasks = loadTasks();
      
      // 检查索引是否有效
      if (index >= 0 && index < tasks.size()) {
        // 更新指定任务
        tasks.set(index, updatedTask);
        
        // 保存更新后的任务列表
        saveTasks(tasks);
        println("Task updated and saved to file");
      } else {
        println("Error: Invalid task index: " + index);
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
  
  // 添加 getter 方法
  public boolean isDirty() {
    return isDirty;
  }
  
  // 导出数据到ZIP文件
  public void exportDataToZip() {
    try {
      // 创建导出目录
      java.io.File exportDir = new java.io.File(android.os.Environment.getExternalStoragePublicDirectory(
          android.os.Environment.DIRECTORY_DOWNLOADS), "StaryTimer");
      if (!exportDir.exists()) {
        exportDir.mkdirs();
      }
      
      // 获取应用私有目录
      java.io.File appDir = activity.getExternalFilesDir(null);
      
      // 创建ZIP文件
      String timeStamp = new java.text.SimpleDateFormat("yyyyMMdd_HHmmss", java.util.Locale.getDefault()).format(new java.util.Date());
      java.io.File zipFile = new java.io.File(exportDir, "StaryTimer_" + timeStamp + ".zip");
      
      // 创建ZIP输出流
      java.util.zip.ZipOutputStream zos = new java.util.zip.ZipOutputStream(new java.io.FileOutputStream(zipFile));
      
      // 将应用私有目录中的所有文件添加到ZIP
      addDirectoryToZip(zos, appDir, appDir.getAbsolutePath());
      
      zos.close();
      
      // 使ZIP文件在文件管理器中可见
      android.content.Intent mediaScanIntent = new android.content.Intent(android.content.Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
      mediaScanIntent.setData(android.net.Uri.fromFile(zipFile));
      activity.sendBroadcast(mediaScanIntent);
      
      // 显示导出成功信息
      showToast("\u6570\u636e\u5df2\u5bfc\u51fa\u5230: " + zipFile.getAbsolutePath()); // "数据已导出到: "
      
    } catch (Exception e) {
      showToast("\u5bfc\u5165\u5931\u8d25: " + e.getMessage()); // "导出失败: "
      e.printStackTrace();
    }
  }
  
  // 将目录及其所有子文件添加到ZIP
  private void addDirectoryToZip(java.util.zip.ZipOutputStream zos, java.io.File directory, String basePath) throws Exception {
    java.io.File[] files = directory.listFiles();
    if (files == null) {
      return;
    }
    
    for (java.io.File file : files) {
      // 计算相对路径作为ZIP中的条目名
      String entryName = file.getAbsolutePath().substring(basePath.length() + 1).replace("\\", "/");
      
      if (file.isDirectory()) {
        // 添加目录条目
        if (!entryName.isEmpty()) {
          java.util.zip.ZipEntry dirEntry = new java.util.zip.ZipEntry(entryName + "/");
          zos.putNextEntry(dirEntry);
          zos.closeEntry();
        }
        
        // 处理子目录
        addDirectoryToZip(zos, file, basePath);
      } else {
        // 添加文件
        addFileToZip(zos, entryName, file.getAbsolutePath());
      }
    }
  }
  
  // 将文件添加到ZIP
  private void addFileToZip(java.util.zip.ZipOutputStream zos, String fileName, String filePath) throws Exception {
    java.io.File file = new java.io.File(filePath);
    if (!file.exists()) {
      return;
    }
    
    byte[] buffer = new byte[1024];
    java.io.FileInputStream fis = new java.io.FileInputStream(file);
    zos.putNextEntry(new java.util.zip.ZipEntry(fileName));
    
    int length;
    while ((length = fis.read(buffer)) > 0) {
      zos.write(buffer, 0, length);
    }
    
    zos.closeEntry();
    fis.close();
  }
  
  // 导入数据从ZIP文件
  public void importDataFromZip(final StaryTimerAndroid app) {
    try {
      // 使用系统文件选择器
      android.content.Intent intent = new android.content.Intent(android.content.Intent.ACTION_OPEN_DOCUMENT);
      intent.addCategory(android.content.Intent.CATEGORY_OPENABLE);
      intent.setType("application/zip");
      activity.startActivityForResult(intent, 2); // 使用requestCode 2表示导入操作
      
      // 设置回调处理选择结果
      app.registerActivityResult(new ActivityResultCallback() {
        public void handleResult(int requestCode, int resultCode, android.content.Intent data) {
          if (requestCode == 2 && resultCode == android.app.Activity.RESULT_OK && data != null) {
            try {
              android.net.Uri selectedZipUri = data.getData();
              
              // 获取持久权限
              final int takeFlags = data.getFlags() & 
                  (android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION);
              activity.getContentResolver().takePersistableUriPermission(
                  selectedZipUri, takeFlags);
                  
              // 处理ZIP文件
              processZipFile(selectedZipUri, app);
              
            } catch (Exception e) {
              showToast("\u5bfc\u5165\u5931\u8d25: " + e.getMessage()); // "导入失败: "
              e.printStackTrace();
            }
          }
        }
      });
      
    } catch (Exception e) {
      showToast("\u5bfc\u5165\u5931\u8d25: " + e.getMessage()); // "导入失败: "
      e.printStackTrace();
    }
  }
  
  // 处理导入的ZIP文件
  private void processZipFile(android.net.Uri zipUri, StaryTimerAndroid app) {
    try {
      // 获取应用私有存储目录
      java.io.File appDir = activity.getExternalFilesDir(null);
      
      // 删除现有的数据文件
      clearDirectory(appDir);
      
      // 解压ZIP文件内容
      java.io.InputStream inputStream = activity.getContentResolver().openInputStream(zipUri);
      java.util.zip.ZipInputStream zis = new java.util.zip.ZipInputStream(inputStream);
      java.util.zip.ZipEntry zipEntry;
      
      while ((zipEntry = zis.getNextEntry()) != null) {
        String fileName = zipEntry.getName();
        java.io.File outputFile = new java.io.File(appDir, fileName);
        
        // 如果是目录，创建目录
        if (zipEntry.isDirectory()) {
          outputFile.mkdirs();
          continue;
        }
        
        // 确保父目录存在
        if (outputFile.getParentFile() != null && !outputFile.getParentFile().exists()) {
          outputFile.getParentFile().mkdirs();
        }
        
        // 创建输出文件
        java.io.FileOutputStream fos = new java.io.FileOutputStream(outputFile);
        
        byte[] buffer = new byte[1024];
        int length;
        while ((length = zis.read(buffer)) > 0) {
          fos.write(buffer, 0, length);
        }
        
        fos.close();
      }
      
      zis.close();
      inputStream.close();
      
      // 重新初始化各个管理器
      app.reinitializeSceneManager();
      app.reinitializeTaskManager();
      app.reinitializeAccount();
      app.reinitializeBackgroundManager();
      app.reinitializeStarManager();
      
      // 最后提示导入成功
      showToast("\u5bfc\u5165\u6570\u636e\u6210\u529f");
      
    } catch (Exception e) {
      showToast("\u5904\u7406\u5bfc\u5165\u6587\u4ef6\u5931\u8d25: " + e.getMessage()); // "处理导入文件失败: "
      e.printStackTrace();
    }
  }
  
  // 清空目录中的所有文件
  private void clearDirectory(java.io.File directory) {
    if (directory == null || !directory.exists() || !directory.isDirectory()) {
      return;
    }
    
    java.io.File[] files = directory.listFiles();
    if (files != null) {
      for (java.io.File file : files) {
        if (file.isDirectory()) {
          clearDirectory(file); // 递归清空子目录
        }
        file.delete(); // 删除文件或空目录
      }
    }
  }
  
  // 显示Toast消息
  private void showToast(final String message) {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.widget.Toast.makeText(activity, message, android.widget.Toast.LENGTH_SHORT).show();
      }
    });
  }
} 
