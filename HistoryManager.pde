class HistoryManager {
  private PApplet parent;
  private Activity activity;
  private FileManager fileManager;
  private UI ui;
  private ArrayList<HistoryRecord> historyRecords;
  
  // 历史记录列表视图相关变量
  private float recordItemHeight = 120;
  private float recordListPadding = 50;
  private boolean isHistoryListVisible = false;
  
  // 滚动相关变量
  private float scrollY = 0;
  private float maxScrollY = 0;
  
  // 添加翻页相关变量
  private int currentPage = 0;
  private int recordsPerPage = 6; // 每页显示6个记录，从5改为6
  
  // 添加图片资源
  private PImage recordBackgroundImage; // 历史记录背景图片
  private PImage pageButtonImage; // 翻页按钮背景图片
  private PImage ashbinIcon; // 删除图标
  private PImage backIcon; // 返回按钮图标
  
  // 添加重叠度变量
  private float recordOverlap = -60; // 记录项重叠度，负值表示重叠
  
  HistoryManager(PApplet parent, UI ui, FileManager fileManager) {
    this.parent = parent;
    this.activity = ((StaryTimerAndroid)parent).getActivity();
    this.ui = ui;
    this.fileManager = fileManager;
    this.historyRecords = new ArrayList<HistoryRecord>();
    
    // 加载图片资源
    this.recordBackgroundImage = parent.loadImage("taskBackground.png"); // 使用相同的背景图片
    this.pageButtonImage = parent.loadImage("pageupdn.png");
    this.ashbinIcon = parent.loadImage("ashbin.png");
    this.backIcon = parent.loadImage("back.png"); // 加载返回按钮图标
    
    // 初始化加载历史记录
    loadHistoryRecords();
  }
  
  // 加载历史记录
  void loadHistoryRecords() {
    // 清空当前历史记录列表
    historyRecords.clear();
    
    // 获取当前场景名称
    String currentScene = ((StaryTimerAndroid)parent).sceneManager.getCurrentSceneName();
    String fileName = "scene_" + currentScene + ".json";
    
    try {
      java.io.File storageDir = activity.getExternalFilesDir(null);
      java.io.File file = new java.io.File(storageDir, fileName);
      
      if (!file.exists() || !file.canRead() || file.length() == 0) {
        return;
      }
      
      String[] lines = parent.loadStrings(file.getAbsolutePath());
      if (lines != null && lines.length > 0) {
        String jsonStr = parent.join(lines, "");
        
        if (jsonStr == null || jsonStr.trim().isEmpty() || jsonStr.equals("null")) {
          return;
        }
        
        JSONArray savedStars = parent.parseJSONArray(jsonStr);
        
        // 遍历数据创建历史记录对象
        for (int i = 0; i < savedStars.size(); i++) {
          JSONObject starData = savedStars.getJSONObject(i);
          
          String taskName = starData.getString("taskName", "未命名任务");
          long duration = starData.getLong("duration", 0);
          
          // 从date字段获取日期并转换为时间戳
          long timestamp;
          if (starData.hasKey("date")) {
            String dateStr = starData.getString("date");
            timestamp = convertDateStringToTimestamp(dateStr);
          } else {
            // 如果找不到日期字段，使用当前时间作为备选
            timestamp = System.currentTimeMillis();
          }
          
          HistoryRecord record = new HistoryRecord(taskName, duration, timestamp);
          historyRecords.add(record);
        }
        
        // 按时间戳排序，最新的记录在前面
        sortHistoryRecords();
      }
    } catch (Exception e) {
      System.err.println("Error loading history records: " + e.getMessage());
      e.printStackTrace();
    }
    
    // 重置翻页
    currentPage = 0;
    
    // 计算最大滚动范围
    calculateMaxScrollY();
  }
  
  // 将日期字符串转换为时间戳
  private long convertDateStringToTimestamp(String dateStr) {
    try {
      java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
      return dateFormat.parse(dateStr).getTime();
    } catch (Exception e) {
      System.err.println("Error parsing date: " + dateStr);
      // 如果无法解析，返回当前时间
      return System.currentTimeMillis();
    }
  }
  
  // 对历史记录按照时间戳进行排序（从新到旧）
  private void sortHistoryRecords() {
    java.util.Collections.sort(historyRecords, new java.util.Comparator<HistoryRecord>() {
      public int compare(HistoryRecord r1, HistoryRecord r2) {
        // 降序排列，最新的在前面
        return Long.compare(r2.getTimestamp(), r1.getTimestamp());
      }
    });
  }
  
  // 计算最大滚动范围
  private void calculateMaxScrollY() {
    float clipHeight = parent.height - 2 * recordListPadding - 140; // 减去标题和底部空间
    maxScrollY = Math.max(0, historyRecords.size() * recordItemHeight - clipHeight);
  }
  
  // 显示历史记录列表
  void showHistoryList() {
    isHistoryListVisible = true;
    scrollY = 0;
  }
  
  // 隐藏历史记录列表
  void hideHistoryList() {
    isHistoryListVisible = false;
    scrollY = 0;
  }
  
  // 绘制历史记录列表
  void drawHistoryList() {
    if (!isHistoryListVisible) return;
    
    try {
      parent.pushStyle();
      
      // 绘制标题 - 修改样式和位置与其他标题保持一致
      parent.fill(255);
      parent.textAlign(CENTER, TOP);
      parent.textSize(70);
      // 使用UI类中预加载的粗体字体
      PFont boldFont = ((StaryTimerAndroid)parent).ui.getBoldFont();
      if (boldFont != null) {
        parent.textFont(boldFont);
      }
      float titleY = parent.height/14; // 调整为与其他标题相同的位置（height/14）
      parent.text("\u5386\u53f2\u8bb0\u5f55", parent.width/2, titleY); // "历史记录"
      
      // 绘制返回按钮，与option.png位置一致
      if (backIcon != null) {
        float backIconSize = 216; // 设置返回按钮大小为216x216
        // 获取UI类中option.png的位置
        float backIconX = ((StaryTimerAndroid)parent).ui.getOptionIconX();
        float backIconY = ((StaryTimerAndroid)parent).ui.getOptionIconY();
        
        parent.imageMode(CENTER);
        parent.image(backIcon, backIconX, backIconY, backIconSize, backIconSize);
        parent.imageMode(CORNER);
      }
      
      // 安全检查
      if (historyRecords == null) {
        parent.popStyle();
        return;
      }
      
      // 如果没有历史记录，显示提示信息
      if (historyRecords.size() == 0) {
        parent.fill(255);
        parent.textAlign(CENTER, CENTER);
        parent.textSize(40);
        parent.text("\u6ca1\u6709\u5386\u53f2\u8bb0\u5f55", parent.width/2, parent.height/2); // "没有历史记录"
        parent.popStyle();
        return;
      }
      
      // 计算背景图片的高度（与TaskManager保持一致）
      float bgHeight = parent.width * 0.295f; // 高度为屏幕宽度的29.5%
      
      // 更新记录项高度以匹配背景图片
      recordItemHeight = bgHeight;
      
      // 定义可视区域的范围 - 与TaskManager保持一致，但要适应新的标题位置
      float visibleAreaTop = titleY + 150; // 从标题位置开始计算
      float visibleAreaHeight = parent.height - visibleAreaTop - recordListPadding - 400;
      float visibleAreaBottom = visibleAreaTop + visibleAreaHeight;
      
      // 计算总页数
      int totalPages = (int)Math.ceil((float)historyRecords.size() / recordsPerPage);
      if (totalPages == 0) totalPages = 1; // 确保至少有一页
      
      // 确保当前页在有效范围内
      currentPage = constrain(currentPage, 0, Math.max(0, totalPages - 1));
      
      // 计算当前页的起始和结束索引
      int startIndex = currentPage * recordsPerPage;
      int endIndex = Math.min(startIndex + recordsPerPage, historyRecords.size());
      
      // 绘制当前页的历史记录
      for (int i = startIndex; i < endIndex; i++) {
        try {
          HistoryRecord record = historyRecords.get(i);
          if (record == null) continue; // 跳过空记录
          
          // 计算在页面中的位置（使用负间距让记录重叠）
          int pageIndex = i - startIndex;
          float y = visibleAreaTop + pageIndex * (bgHeight + recordOverlap);
          
          // 绘制记录项背景图片
          if (recordBackgroundImage != null) {
            float bgWidth = parent.width;
            parent.image(recordBackgroundImage, 0, y, bgWidth, bgHeight);
          }
          
          // 垂直居中位置
          float centerY = y + bgHeight/2;
          
          // 绘制任务名称
          String taskName = record.getTaskName();
          if (taskName != null) {
            parent.fill(255);
            parent.textSize(40);
            parent.textAlign(LEFT, CENTER);
            parent.text(taskName, recordListPadding + 80, centerY - 20); // 上移到垂直居中位置上方
          }
          
          // 绘制持续时间
          String durationText = "\u65f6\u957f: " + formatDuration(record.getDuration()); // "时长: "
          parent.textSize(30);
          parent.text(durationText, recordListPadding + 80, centerY + 30); // 下移到垂直居中位置下方
          
          // 绘制日期
          String dateText = record.getFormattedTimestamp();
          parent.text(dateText, recordListPadding + 310, centerY + 30); // 与持续时间同一水平线
          
          // 绘制删除按钮
          float deleteIconX = parent.width - recordListPadding - 150; // 与TaskManager保持一致
          float deleteIconY = centerY;
          
          if (ashbinIcon != null) {
            // 使用imageMode(CENTER)使图片居中显示
            parent.imageMode(CENTER);
            parent.image(ashbinIcon, deleteIconX, deleteIconY, 72, 72); // 设置大小为72x72
            parent.imageMode(CORNER); // 恢复默认imageMode
          } else {
            // 如果图标加载失败，使用原来的X按钮作为备用
            parent.fill(255, 100, 100);
            parent.rect(deleteIconX - 30, deleteIconY - 30, 60, 60, 10);
            parent.fill(255);
            parent.textSize(40);
            parent.textAlign(CENTER, CENTER);
            parent.text("X", deleteIconX, deleteIconY);
          }
        } catch (Exception e) {
          System.err.println("Error drawing record " + i + ": " + e.getMessage());
        }
      }
      
      // 绘制翻页按钮 - 放在原本底部导航栏的位置
      float pageButtonsY = parent.height - parent.width/8; // 放在接近屏幕底部的位置，考虑到导航栏高度约为屏幕宽度的1/4
      drawPageButtons(pageButtonsY, totalPages);
      
      parent.popStyle();
    } catch (Exception e) {
      System.err.println("Error in drawHistoryList: " + e.getMessage());
      e.printStackTrace();
      try {
        parent.popStyle();
      } catch (Exception ex) {
        // 忽略
      }
    }
  }
  
  // 绘制翻页按钮 - 更新为TaskManager的样式
  private void drawPageButtons(float y, int totalPages) {
    if (totalPages <= 1) return; // 只有一页不需要翻页按钮
    
    // 更新按钮尺寸为420x210，与TaskManager保持一致
    float buttonWidth = 420;
    float buttonHeight = 210;
    float spacing = 80; // 按钮之间的间距
    
    // 绘制页码信息
    parent.fill(255);
    parent.textSize(40); // 增大文字大小
    parent.textAlign(CENTER, CENTER);
    parent.text((currentPage + 1) + " / " + totalPages, parent.width/2, y);
    
    // 绘制上一页按钮
    if (currentPage > 0) {
      if (pageButtonImage != null) {
        // 使用图片作为背景
        parent.imageMode(CENTER);
        float buttonX = parent.width/2 - buttonWidth/2 - spacing;
        parent.image(pageButtonImage, buttonX, y, buttonWidth, buttonHeight);
        parent.imageMode(CORNER);
      } else {
        // 如果图片未加载成功，使用原来的矩形作为备用
        parent.fill(50, 50, 200);
        parent.rect(parent.width/2 - buttonWidth - spacing, y - buttonHeight/2, buttonWidth, buttonHeight, 10);
      }
      
      // 绘制文字
      parent.fill(255);
      parent.textSize(50); // 增大按钮文字大小
      parent.textAlign(CENTER, CENTER);
      // 将文字位置往下移15像素，更好地居中在按钮中央
      parent.text("\u4e0a\u4e00\u9875", parent.width/2 - buttonWidth/2 - spacing, y + 15); // "上一页"
    }
    
    // 绘制下一页按钮
    if (currentPage < totalPages - 1) {
      if (pageButtonImage != null) {
        // 使用图片作为背景
        parent.imageMode(CENTER);
        float buttonX = parent.width/2 + buttonWidth/2 + spacing;
        parent.image(pageButtonImage, buttonX, y, buttonWidth, buttonHeight);
        parent.imageMode(CORNER);
      } else {
        // 如果图片未加载成功，使用原来的矩形作为备用
        parent.fill(50, 50, 200);
        parent.rect(parent.width/2 + spacing, y - buttonHeight/2, buttonWidth, buttonHeight, 10);
      }
      
      // 绘制文字
      parent.fill(255);
      parent.textSize(50); // 增大按钮文字大小
      parent.textAlign(CENTER, CENTER);
      // 将文字位置往下移15像素，更好地居中在按钮中央
      parent.text("\u4e0b\u4e00\u9875", parent.width/2 + buttonWidth/2 + spacing, y + 15); // "下一页"
    }
  }
  
  // 处理翻页按钮点击 - 更新为TaskManager的样式
  boolean handlePageButtonClick(float x, float y) {
    if (!isHistoryListVisible) return false;
    
    float titleY = parent.height/14; // 调整为与绘制函数中相同的位置（height/14）
    float visibleAreaTop = titleY + 150; // 与绘制函数中的值保持一致
    
    // 获取可视区域底部位置（与绘制函数中的计算保持一致）
    float visibleAreaHeight = parent.height - visibleAreaTop - recordListPadding - 400;
    float visibleAreaBottom = visibleAreaTop + visibleAreaHeight;
    
    // 更新按钮Y位置到与drawPageButtons中相同的位置
    float pageButtonsY = parent.height - parent.width/8;
    float buttonY = pageButtonsY; // 使用新计算的位置
    
    // 更新按钮尺寸为420x210，与绘制函数保持一致
    float buttonWidth = 420;
    float buttonHeight = 210;
    float spacing = 80; // 增加间距，与绘制时保持一致
    
    // 计算总页数
    int totalPages = (int)Math.ceil((float)historyRecords.size() / recordsPerPage);
    if (totalPages <= 1) return false; // 只有一页不需要翻页按钮
    
    // 检查上一页按钮点击
    if (currentPage > 0) {
      float leftButtonX = parent.width/2 - buttonWidth/2 - spacing;
      // 使用矩形区域检测，确保整个按钮区域可点击
      if (x >= leftButtonX - buttonWidth/2 && x <= leftButtonX + buttonWidth/2 &&
          y >= buttonY - buttonHeight/2 && y <= buttonY + buttonHeight/2) {
        currentPage--;
        return true;
      }
    }
    
    // 检查下一页按钮点击
    if (currentPage < totalPages - 1) {
      float rightButtonX = parent.width/2 + buttonWidth/2 + spacing;
      // 使用矩形区域检测，确保整个按钮区域可点击
      if (x >= rightButtonX - buttonWidth/2 && x <= rightButtonX + buttonWidth/2 &&
          y >= buttonY - buttonHeight/2 && y <= buttonY + buttonHeight/2) {
        currentPage++;
        return true;
      }
    }
    
    return false;
  }
  
  // 格式化持续时间
  private String formatDuration(long durationMillis) {
    long hours = durationMillis / (3600 * 1000);
    long minutes = (durationMillis % (3600 * 1000)) / (60 * 1000);
    long seconds = (durationMillis % (60 * 1000)) / 1000;
    
    return String.format("%02d:%02d:%02d", hours, minutes, seconds);
  }
  
  // 删除历史记录
  void removeHistoryRecord(int index) {
    if (index >= 0 && index < historyRecords.size()) {
      // 从列表中删除记录
      historyRecords.remove(index);
      
      // 保存更改
      saveHistoryRecords();
      
      // 重新加载星星数据以更新背景
      fileManager.loadStars();
      
      // 重新计算最大页数并检查当前页是否仍然有效
      int totalPages = (int)Math.ceil((float)historyRecords.size() / recordsPerPage);
      if (totalPages == 0) totalPages = 1; // 确保至少有一页
      
      // 如果当前页超出了最大页数，调整到最后一页
      if (currentPage >= totalPages) {
        currentPage = Math.max(0, totalPages - 1);
      }
    }
  }
  
  // 保存历史记录到JSON文件
  void saveHistoryRecords() {
    // 获取当前场景名称
    String currentScene = ((StaryTimerAndroid)parent).sceneManager.getCurrentSceneName();
    String fileName = "scene_" + currentScene + ".json";
    
    try {
      java.io.File storageDir = activity.getExternalFilesDir(null);
      java.io.File file = new java.io.File(storageDir, fileName);
      
      if (!file.exists()) {
        System.err.println("File does not exist: " + file.getAbsolutePath());
        return;
      }
      
      // 读取原始JSON字符串
      String[] lines = parent.loadStrings(file.getAbsolutePath());
      if (lines == null || lines.length == 0) {
        System.err.println("No content in file: " + file.getAbsolutePath());
        return;
      }
      
      String jsonStr = parent.join(lines, "");
      JSONArray savedStars = parent.parseJSONArray(jsonStr);
      
      // 创建新的JSON数组，只包含未删除的记录
      JSONArray newStarsArray = new JSONArray();
      
      // 用historyRecords列表中的记录来重建JSON数组
      for (HistoryRecord record : historyRecords) {
        // 查找原始数据中匹配的记录
        for (int i = 0; i < savedStars.size(); i++) {
          JSONObject starData = savedStars.getJSONObject(i);
          String taskName = starData.getString("taskName", "未命名任务");
          long duration = starData.getLong("duration", 0);
          String date = starData.getString("date", "");
          
          // 如果找到匹配的记录（根据时间戳和任务名称匹配）
          if (taskName.equals(record.getTaskName()) && 
              duration == record.getDuration() &&
              date.equals(record.getFormattedTimestamp())) {
            newStarsArray.append(starData);
            break;
          }
        }
      }
      
      // 保存新的JSON数组到文件
      parent.saveStrings(file.getAbsolutePath(), new String[] { newStarsArray.toString() });
      
      System.out.println("保存更新后的历史记录成功");
    } catch (Exception e) {
      System.err.println("Error saving history records: " + e.getMessage());
      e.printStackTrace();
    }
  }
  
  // 显示删除确认对话框
  void showDeleteConfirmDialog(final int recordIndex) {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u5220\u9664\u8bb0\u5f55");  // "删除记录"
        builder.setMessage("\u4f60\u786e\u5b9a\u8981\u5220\u9664\u8fd9\u6761\u8bb0\u5f55\u5417\uff1f");  // "你确定要删除这条记录吗？"
        
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() {  // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            removeHistoryRecord(recordIndex);
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
  
  // 检查删除按钮点击 - 更新为TaskManager的样式
  boolean handleDeleteButtonClick(float x, float y) {
    if (!isHistoryListVisible) return false;
    
    float titleY = parent.height/14; // 调整为与绘制函数中相同的位置（height/14）
    float visibleAreaTop = titleY + 150; // 与绘制函数中的值保持一致
    
    // 计算背景图片的高度（与绘制函数保持一致）
    float bgHeight = parent.width * 0.295f;
    
    // 计算当前页的起始和结束索引
    int startIndex = currentPage * recordsPerPage;
    int endIndex = Math.min(startIndex + recordsPerPage, historyRecords.size());
    
    for (int i = startIndex; i < endIndex; i++) {
      // 计算在页面中的位置（使用与绘制相同的计算方式）
      int pageIndex = i - startIndex;
      float itemY = visibleAreaTop + pageIndex * (bgHeight + recordOverlap);
      float centerY = itemY + bgHeight/2;
      
      // 检查是否点击了删除按钮
      float deleteIconX = parent.width - recordListPadding - 150; // 与绘制函数保持一致
      float deleteIconY = centerY;
      
      if (dist(x, y, deleteIconX, deleteIconY) <= 36) { // 使用距离检测，半径为36（图标尺寸的一半）
        showDeleteConfirmDialog(i);
        return true;
      }
    }
    
    return false;
  }
  
  // 检查返回按钮点击 - 更新位置与option.png一致
  boolean isBackButtonClicked(float x, float y) {
    if (!isHistoryListVisible) return false;
    
    // 获取UI类中option.png的位置和大小
    float backIconX = ((StaryTimerAndroid)parent).ui.getOptionIconX();
    float backIconY = ((StaryTimerAndroid)parent).ui.getOptionIconY();
    float backIconSize = ((StaryTimerAndroid)parent).ui.getOptionIconSize();
    
    // 使用距离检测确认点击
    return dist(x, y, backIconX, backIconY) <= backIconSize/2;
  }
  
  // 处理返回按钮点击，导航到"我的"界面
  void handleBackButtonClick() {
    if (isHistoryListVisible) {
      // 隐藏历史记录列表
      hideHistoryList();
      
      // 切换到"我的"界面 - 使用正确的方式
      StaryTimerAndroid app = (StaryTimerAndroid)parent;
      app.clearAllModes(); // 先清除所有模式标志
      app.isAccountMode = true; // 然后设置为账户模式
      
      // 如果需要，可以添加其他清理或转换代码
      System.out.println("导航到我的界面");
    }
  }
}

// 历史记录类
class HistoryRecord {
  private String taskName;
  private long duration; // 持续时间（毫秒）
  private long timestamp; // 记录创建时间戳
  
  HistoryRecord(String taskName, long duration, long timestamp) {
    this.taskName = taskName;
    this.duration = duration;
    this.timestamp = timestamp;
  }
  
  String getTaskName() {
    return taskName;
  }
  
  long getDuration() {
    return duration;
  }
  
  long getTimestamp() {
    return timestamp;
  }
  
  String getFormattedTimestamp() {
    java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
    return dateFormat.format(new java.util.Date(timestamp));
  }
} 