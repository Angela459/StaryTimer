class TaskManager {
  private PApplet parent;
  private Activity activity;
  private ArrayList<Task> tasks;
  private UI ui;
  private FileManager fileManager;  // 添加FileManager引用
  private int selectedTaskIndex = -1;
  private PImage ashbinIcon; // 添加删除图标变量
  private PImage taskBackgroundImage; // 添加任务背景图片
  private PImage pageButtonImage; // 添加翻页按钮背景图片
  private PImage toggleDoneIcon; // 添加已完成任务图标
  private PImage toggleToDoIcon; // 添加未完成任务图标
  
  // 任务列表视图相关变量
  private float taskItemHeight = 120;
  private float taskListPadding = 50;
  private boolean isTaskListVisible = false;
  private float taskOverlap = -60; // 添加任务重叠度作为成员变量，负值表示重叠
  
  // 任务模式状态变量
  private boolean isTaskMode = false;
  
  // 滚动相关变量
  private float scrollY = 0;
  private float maxScrollY = 0;
  
  // 添加翻页相关变量
  private int currentPage = 0;
  private int tasksPerPage = 5; // 每页显示5个任务（从8改为5）
  
  TaskManager(PApplet parent, UI ui, FileManager fileManager) {
    this.parent = parent;
    this.activity = ((StaryTimerAndroid)parent).getActivity();
    this.ui = ui;
    this.fileManager = fileManager;  // 保存FileManager引用
    this.tasks = new ArrayList<Task>();
    
    // 加载删除图标
    this.ashbinIcon = parent.loadImage("ashbin.png");
    
    // 加载任务背景图片
    this.taskBackgroundImage = parent.loadImage("taskBackground.png");
    
    // 加载翻页按钮背景图片
    this.pageButtonImage = parent.loadImage("pageupdn.png");
    
    // 加载任务状态图标
    this.toggleDoneIcon = parent.loadImage("toggleDone.png");
    this.toggleToDoIcon = parent.loadImage("toggleToDo.png");
    
    // 加载保存的任务
    loadTasks();
    
    // 如果没有任务，添加一个默认任务
    if (tasks.size() == 0) {
      addTask(new Task("\u5b66\u4e60", 0)); // "学习"
    }
  }
  
  // 检查是否在任务模式
  boolean isInTaskMode() {
    return isTaskMode;
  }
  
  // 加载保存的任务
  void loadTasks() {
    // 从JSON文件加载任务
    ArrayList<Task> loadedTasks = fileManager.loadTasks();
    
    // 清空当前任务列表
    tasks.clear();
    
    // 添加加载的任务
    if (loadedTasks != null && loadedTasks.size() > 0) {
      tasks.addAll(loadedTasks);
    }
    
    // 如果没有任务，添加默认任务
    if (tasks.isEmpty()) {
      Task defaultTask = new Task("\u5b66\u4e60", 0); // "学习"
      addTask(defaultTask);
    }
    
    // 设置默认选中第一个任务
    selectedTaskIndex = 0;
  }
  
  // 保存任务
  void saveTasks() {
    // 保存任务到JSON文件
    fileManager.saveTasks(tasks);
  }
  
  // 添加新任务
  void addTask(Task task) {
    tasks.add(task);
    saveTasks();
  }
  
  // 删除任务
  void deleteTask(int index) {
    if (index >= 0 && index < tasks.size()) {
      tasks.remove(index);
      
      // 如果删除的是当前选中的任务，更新选中索引
      if (selectedTaskIndex >= tasks.size()) {
        selectedTaskIndex = Math.max(0, tasks.size() - 1);
      }
      
      saveTasks();  // 保存任务列表
      
      // 如果任务列表为空，添加默认任务
      if (tasks.isEmpty()) {
        Task defaultTask = new Task("\u5b66\u4e60", 0); // "学习"
        addTask(defaultTask);
        selectedTaskIndex = 0;
      }
    }
  }
  
  // 更新任务完成情况
  void updateTaskCompletion(String taskName, long duration) {
    for (Task task : tasks) {
      if (task.getName().equals(taskName)) {
        task.addCompletedTime(duration);
        task.incrementCompletedCount();
        saveTasks();
        break;
      }
    }
  }
  
  // 获取当前选中的任务
  Task getSelectedTask() {
    if (selectedTaskIndex >= 0 && selectedTaskIndex < tasks.size()) {
      return tasks.get(selectedTaskIndex);
    }
    
    // 如果没有选中任务，返回第一个任务或创建一个默认任务
    if (tasks.size() > 0) {
      selectedTaskIndex = 0;
      return tasks.get(0);
    } else {
      Task defaultTask = new Task("\u5b66\u4e60", 0); // "学习"
      addTask(defaultTask);
      selectedTaskIndex = 0;
      return defaultTask;
    }
  }
  
  // 设置任务模式状态
  void setTaskMode(boolean isTaskMode) {
    this.isTaskMode = isTaskMode;
    
    // 当进入任务模式时，自动显示任务列表
    if (isTaskMode) {
      showTaskList();
    } else {
      hideTaskList();
    }
  }
  
  // 显示任务列表
  void showTaskList() {
    isTaskListVisible = true;
    
    // 计算最大滚动范围
    float clipHeight = parent.height - 2 * taskListPadding - 80 - 60; // 减去底部按钮的高度
    maxScrollY = Math.max(0, tasks.size() * taskItemHeight - clipHeight);
    
    // 重置滚动位置
    scrollY = 0;
  }
  
  // 隐藏任务列表
  void hideTaskList() {
    isTaskListVisible = false;
    scrollY = 0;
  }
  
  // 绘制任务列表（翻页版本）
  void drawTaskList() {
    if (!isTaskListVisible) return;
    
    try {
      parent.pushStyle();

      float titleY = taskListPadding + 150;
      
      // 安全检查
      if (tasks == null) {
        parent.popStyle();
        return;
      }
      
      // 计算任务背景的高度（使其全局可用）
      float bgHeight = parent.width * 0.295f; // 高度为屏幕宽度的29.5%
      
      // 使用成员变量taskOverlap，不再在这里定义局部变量
      
      // 更新任务项高度以匹配背景图片
      taskItemHeight = bgHeight;
      
      // 定义可视区域的范围 - 调整以适应新的任务高度
      float visibleAreaTop = titleY + 150; // 降低起始位置，让内容更靠上
      float visibleAreaHeight = parent.height - visibleAreaTop - taskListPadding - 400;
      float visibleAreaBottom = visibleAreaTop + visibleAreaHeight;
      
      // 绘制添加任务图标(add.png)
      PImage addIcon = ui.getAddImage();
      if (addIcon != null) {
        float addIconX = parent.width * 0.9 - 72; // 屏幕右侧，调整位置
        float addIconY = titleY; // 调整Y位置与"任务列表"标题对齐
        parent.imageMode(CENTER);
        parent.image(addIcon, addIconX, addIconY, 216, 216); // 将大小从288x288减小到216x216（0.75倍）
        parent.imageMode(CORNER);
      }
      
      // 计算总页数
      int totalPages = (int)Math.ceil((float)tasks.size() / tasksPerPage);
      
      // 确保当前页在有效范围内
      currentPage = constrain(currentPage, 0, Math.max(0, totalPages - 1));
      
      // 确保任务列表不为空
      if (tasks.size() > 0) {
        // 计算当前页的起始和结束索引
        int startIndex = currentPage * tasksPerPage;
        int endIndex = Math.min(startIndex + tasksPerPage, tasks.size());
        
        // 绘制当前页的任务
        for (int i = startIndex; i < endIndex; i++) {
          try {
            Task task = tasks.get(i);
            if (task == null) continue; // 跳过空任务
            
            // 计算在页面中的位置（使用负间距让任务重叠）
            int pageIndex = i - startIndex;
            // 使用成员变量taskOverlap
            float y = visibleAreaTop + pageIndex * (bgHeight + taskOverlap);
            
            // 绘制任务项背景图片
            if (taskBackgroundImage != null) {
              float bgWidth = parent.width;
              parent.image(taskBackgroundImage, 0, y, bgWidth, bgHeight);
            }
            
            // 垂直居中位置
            float centerY = y + bgHeight/2;
            
            // 绘制任务状态图标（已完成/未完成）
            float iconSize = 60; // 图标大小
            float iconX = taskListPadding + 60; // 图标X坐标，向右移动到60
            
            parent.imageMode(CENTER);
            if (task.getCompletedCount() > 0) {
              // 如果任务已完成，绘制toggleDone.png
              if (toggleDoneIcon != null) {
                parent.image(toggleDoneIcon, iconX, centerY, iconSize, iconSize);
              }
            } else {
              // 如果任务未完成，绘制toggleToDo.png
              if (toggleToDoIcon != null) {
                parent.image(toggleToDoIcon, iconX, centerY, iconSize, iconSize);
              }
            }
            parent.imageMode(CORNER);
            
            // 绘制任务名称 - 向右移动
            String name = task.getName();
            if (name != null) {
              parent.fill(255);
              parent.textSize(40);
              parent.textAlign(LEFT, CENTER);
              float taskNameX = taskListPadding + 110; // 向右移动到110
              parent.text(name, taskNameX, centerY - 10); // 稍微上移
              
              // 计算任务名称的宽度
              float taskNameWidth = parent.textWidth(name);
              
              // 绘制完成次数 - 放在任务名称的旁边
              String completionText = "\u5b8c\u6210: " + task.getCompletedCount() + " \u6b21"; // "完成: X 次"
              parent.textSize(30);
              float completionX = taskNameX + taskNameWidth + 20; // 任务名称右侧加上一点间距
              parent.text(completionText, completionX, centerY - 10); // 与任务名称同一高度
            }
            
            // 绘制提醒日期 - 放在任务名称下方，设置青蓝色
            if (task.hasReminder()) {
              parent.fill(0, 180, 220); // 青蓝色
              String reminderText = "\u63d0\u9192: " + task.getFormattedReminderDate(); // "提醒: yyyy-MM-dd"
              float reminderX = taskListPadding + 110; // 与任务名称相同的X位置
              parent.text(reminderText, reminderX, centerY + 30); // 放在任务名称下方
              parent.fill(255); // 恢复默认颜色
            }
            
            // 绘制删除按钮 - 调整位置与背景匹配
            float deleteIconX = parent.width - taskListPadding - 150; // 从原来的50改为150，向左移动
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
            System.err.println("Error drawing task " + i + ": " + e.getMessage());
          }
        }
        
        // 绘制翻页按钮
        drawPageButtons(visibleAreaBottom + 50, totalPages);
      }
      
      parent.popStyle();
    } catch (Exception e) {
      System.err.println("Error in drawTaskList: " + e.getMessage());
      e.printStackTrace();
      try {
        parent.popStyle();
      } catch (Exception ex) {
        // 忽略
      }
    }
  }
  
  // 绘制翻页按钮
  void drawPageButtons(float y, int totalPages) {
    if (totalPages <= 1) return; // 只有一页不需要翻页按钮
    
    // 更新按钮尺寸为420x210
    float buttonWidth = 420;
    float buttonHeight = 210;
    float spacing = 80; // 按钮之间的间距
    
    // 绘制页码信息
    parent.fill(255);
    parent.textSize(40); // 增大文字大小，从30改为40
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
      parent.textSize(50); // 增大按钮文字大小，从默认改为50
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
      parent.textSize(50); // 增大按钮文字大小，从默认改为50
      parent.textAlign(CENTER, CENTER);
      // 将文字位置往下移15像素，更好地居中在按钮中央
      parent.text("\u4e0b\u4e00\u9875", parent.width/2 + buttonWidth/2 + spacing, y + 15); // "下一页"
    }
  }
  
  // 处理翻页按钮点击
  boolean handlePageButtonClick(float x, float y) {
    if (!isTaskListVisible) return false;
    
    float titleY = taskListPadding + 150;
    float visibleAreaTop = titleY + 150; // 与绘制函数中的值保持一致
    
    // 获取可视区域底部位置（与绘制函数中的计算保持一致）
    float visibleAreaHeight = parent.height - visibleAreaTop - taskListPadding - 400;
    float visibleAreaBottom = visibleAreaTop + visibleAreaHeight;
    float buttonY = visibleAreaBottom + 50; // 与drawPageButtons中的y值一致
    
    // 更新按钮尺寸为420x210，与绘制函数保持一致
    float buttonWidth = 420;
    float buttonHeight = 210;
    float spacing = 80; // 增加间距，从20改为80，与绘制时保持一致
    
    // 计算总页数
    int totalPages = (int)Math.ceil((float)tasks.size() / tasksPerPage);
    
    // 输出调试信息
    System.out.println("Click position: x=" + x + ", y=" + y);
    System.out.println("Button y position: " + buttonY);
    System.out.println("Button height: " + buttonHeight);
    
    // 检查上一页按钮点击
    if (currentPage > 0) {
      float leftButtonX = parent.width/2 - buttonWidth/2 - spacing;
      // 使用圆形区域检测
      if (dist(x, y, leftButtonX, buttonY) <= buttonWidth/2) {
        currentPage--;
        System.out.println("上一页按钮被点击");
        return true;
      }
    }
    
    // 检查下一页按钮点击
    if (currentPage < totalPages - 1) {
      float rightButtonX = parent.width/2 + buttonWidth/2 + spacing;
      // 使用圆形区域检测
      if (dist(x, y, rightButtonX, buttonY) <= buttonWidth/2) {
        currentPage++;
        System.out.println("下一页按钮被点击");
        return true;
      }
    }
    
    return false;
  }
  
  // 修改检查点击是否在添加任务图标上的方法
  boolean isAddIconClicked(float x, float y) {
    // 使用与绘制相同的位置计算
    float addIconX = parent.width * 0.9 - 72; // 调整位置与绘制时一致
    float titleY = taskListPadding + 150; // 计算与绘制函数中相同的titleY
    float addIconY = titleY; // 使用与绘制函数中相同的Y位置
    float iconSize = 216; // 调整为新的大小216（0.75倍）
    
    // 计算点击是否在图标范围内
    return (dist(x, y, addIconX, addIconY) <= iconSize/2);
  }
  
  // 修改检查点击是否在任务项上的方法，适应新的布局
  int getClickedTaskIndex(float x, float y) {
    if (!isTaskListVisible) return -1;
    
    float titleY = taskListPadding + 150;
    float visibleAreaTop = titleY + 150; // 与绘制函数中的值保持一致
    
    // 计算任务背景的高度（与绘制函数保持一致）
    float bgHeight = parent.width * 0.295f;
    
    // 使用成员变量taskOverlap，不再在这里定义局部变量
    
    // 计算当前页的起始索引
    int startIndex = currentPage * tasksPerPage;
    int endIndex = Math.min(startIndex + tasksPerPage, tasks.size());
    
    for (int i = startIndex; i < endIndex; i++) {
      // 计算在页面中的位置 - 确保使用与绘制相同的计算方式
      int pageIndex = i - startIndex;
      // 使用成员变量taskOverlap
      float itemY = visibleAreaTop + pageIndex * (bgHeight + taskOverlap);
      float centerY = itemY + bgHeight/2;
      
      // 检查是否点击了任务状态图标 - 使用圆形检测
      float iconX = taskListPadding + 60; // 图标中心点X坐标，与绘制时保持一致
      float iconSize = 60; // 图标大小
      
      if (dist(x, y, iconX, centerY) <= iconSize/2) {
        showCompleteTaskConfirmDialog(i);
        return -1; // 返回-1表示点击了完成按钮，不选中任务
      }
      
      // 检查是否点击了删除按钮 - 已经使用圆形检测
      float deleteIconX = parent.width - taskListPadding - 150; // 更新这里的值与绘制函数保持一致
      float deleteIconY = centerY;
      float deleteIconSize = 72; // 删除图标尺寸

      if (dist(x, y, deleteIconX, deleteIconY) <= deleteIconSize/2) {
        showDeleteConfirmDialog(i);
        return -1; // 返回-1表示点击了删除按钮，不选中任务
      }
      
      // 检查点击是否在任务项区域内（排除删除按钮和完成方框）
      // 这里使用矩形区域更合适，因为任务项是一个矩形区域
      float taskAreaLeftX = taskListPadding + 90; // 从图标右侧开始，向右移动
      float taskAreaRightX = deleteIconX - deleteIconSize/2; // 到删除按钮左侧结束
      
      if (x >= taskAreaLeftX && x <= taskAreaRightX && 
          y >= itemY && y <= itemY + bgHeight) {
        return i;
      }
    }
    
    return -1;
  }
  
  // 显示添加任务对话框
  void showAddTaskDialog() {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        // 创建一个垂直布局容器
        android.widget.LinearLayout layout = new android.widget.LinearLayout(activity);
        layout.setOrientation(android.widget.LinearLayout.VERTICAL);
        layout.setPadding(50, 30, 50, 30);
        
        // 创建任务名称输入框
        final android.widget.EditText input = new android.widget.EditText(activity);
        input.setHint("\u8f93\u5165\u4efb\u52a1\u540d\u79f0"); // "输入任务名称"
        layout.addView(input);
        
        // 添加一个间隔
        android.widget.Space space = new android.widget.Space(activity);
        space.setMinimumHeight(30);
        layout.addView(space);
        
        // 创建日期选择器开关
        final android.widget.CheckBox dateCheckBox = new android.widget.CheckBox(activity);
        dateCheckBox.setText("\u8bbe\u7f6e\u63d0\u9192\u65e5\u671f");  // "设置提醒日期"
        layout.addView(dateCheckBox);
        
        // 创建日期选择按钮（初始隐藏）
        final android.widget.Button dateButton = new android.widget.Button(activity);
        dateButton.setText("\u9009\u62e9\u65e5\u671f");  // "选择日期"
        dateButton.setVisibility(android.view.View.GONE);
        layout.addView(dateButton);
        
        // 保存选择的日期
        final java.util.Calendar selectedDate = java.util.Calendar.getInstance();
        final boolean[] dateSelected = {false};
        
        // 设置日期选择器开关的监听器
        dateCheckBox.setOnCheckedChangeListener(new android.widget.CompoundButton.OnCheckedChangeListener() {
          @Override
          public void onCheckedChanged(android.widget.CompoundButton buttonView, boolean isChecked) {
            dateButton.setVisibility(isChecked ? android.view.View.VISIBLE : android.view.View.GONE);
            dateSelected[0] = false;  // 重置日期选择状态
          }
        });
        
        // 设置日期选择按钮的点击监听器
        dateButton.setOnClickListener(new android.view.View.OnClickListener() {
          @Override
          public void onClick(android.view.View v) {
            android.app.DatePickerDialog datePickerDialog = new android.app.DatePickerDialog(
              activity,
              new android.app.DatePickerDialog.OnDateSetListener() {
                @Override
                public void onDateSet(android.widget.DatePicker view, int year, int month, int dayOfMonth) {
                  selectedDate.set(year, month, dayOfMonth);
                  dateSelected[0] = true;
                  dateButton.setText(String.format("%04d-%02d-%02d", year, month + 1, dayOfMonth));
                }
              },
              selectedDate.get(java.util.Calendar.YEAR),
              selectedDate.get(java.util.Calendar.MONTH),
              selectedDate.get(java.util.Calendar.DAY_OF_MONTH)
            );
            datePickerDialog.show();
          }
        });
        
        // 创建对话框
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u6dfb\u52a0\u65b0\u4efb\u52a1");  // "添加新任务"
        builder.setView(layout);
        
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() {  // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            String taskName = input.getText().toString().trim();
            if (!taskName.isEmpty()) {
              Task newTask = new Task(taskName, 0);
              
              // 如果设置了提醒日期，保存到任务中
              if (dateCheckBox.isChecked() && dateSelected[0]) {
                newTask.setReminderDate(selectedDate.getTime());
              }
              
              // 添加任务到列表
              addTask(newTask);
              
              // 设置新添加的任务为选中状态
              selectedTaskIndex = tasks.size() - 1;
              
              // 更新当前任务名称
              ((StaryTimerAndroid)parent).task = taskName;
              
              // 不要在UI线程中直接调用showTaskList()，而是设置一个标志
              isTaskListVisible = true;
              
              // 保存任务列表
              saveTasks();
              
              // 显示成功提示
              ((StaryTimerAndroid)parent).showToast("\u4efb\u52a1\u6dfb\u52a0\u6210\u529f");  // "任务添加成功"
            }
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
  
  // 显示删除确认对话框
  void showDeleteConfirmDialog(final int taskIndex) {
    final Task taskToDelete = tasks.get(taskIndex);
    
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u786e\u8ba4\u5220\u9664"); // "确认删除"
        builder.setMessage("\u60a8\u786e\u5b9a\u8981\u5220\u9664\u4efb\u52a1 \"" + taskToDelete.getName() + "\" \u5417?"); // "您确定要删除任务 "X" 吗?"
        
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() { // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            deleteTask(taskIndex);
          }
        });
        
        builder.setNegativeButton("\u53d6\u6d88", new android.content.DialogInterface.OnClickListener() { // "取消"
          public void onClick(android.content.DialogInterface dialog, int which) {
            dialog.cancel();
          }
        });
        
        builder.show();
      }
    });
  }
  
  // 显示完成任务确认对话框
  void showCompleteTaskConfirmDialog(final int taskIndex) {
    final Task taskToComplete = tasks.get(taskIndex);
    
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u786e\u8ba4\u5b8c\u6210\u4efb\u52a1"); // "确认完成任务"
        builder.setMessage("\u60a8\u786e\u5b9a\u8981\u5c06\u4efb\u52a1 \"" + taskToComplete.getName() + "\" \u6807\u8bb0\u4e3a\u5b8c\u6210\u5417?"); // "您确定要将任务 "X" 标记为完成吗?"
        
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() { // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            // 更新任务完成情况
            taskToComplete.incrementCompletedCount();
            saveTasks();
            
            // 显示成功提示
            ((StaryTimerAndroid)parent).showToast("\u4efb\u52a1\u5df2\u5b8c\u6210");  // "任务已完成"
          }
        });
        
        builder.setNegativeButton("\u53d6\u6d88", new android.content.DialogInterface.OnClickListener() { // "取消"
          public void onClick(android.content.DialogInterface dialog, int which) {
            dialog.cancel();
          }
        });
        
        builder.show();
      }
    });
  }
  
  // 格式化持续时间
  String formatDuration(long durationMillis) {
    try {
      long seconds = durationMillis / 1000;
      long minutes = seconds / 60;
      long hours = minutes / 60;
      
      minutes %= 60;
      seconds %= 60;
      
      return String.format("%02d:%02d:%02d", hours, minutes, seconds);
    } catch (Exception e) {
      // 捕获任何异常，返回默认值
      return "00:00:00";
    }
  }
}

// 任务类
class Task {
  private String name;
  private long totalDuration; // 总时长（毫秒）
  private int completedCount; // 完成次数
  private java.util.Date reminderDate; // 提醒日期
  
  Task(String name, long totalDuration) {
    this.name = name;
    this.totalDuration = totalDuration;
    this.completedCount = 0;
    this.reminderDate = null;
  }
  
  String getName() {
    return name;
  }
  
  void setName(String name) {
    this.name = name;
  }
  
  long getTotalDuration() {
    return totalDuration;
  }
  
  void addCompletedTime(long duration) {
    this.totalDuration += duration;
  }
  
  int getCompletedCount() {
    return completedCount;
  }
  
  void setCompletedCount(int count) {
    this.completedCount = count;
  }
  
  void incrementCompletedCount() {
    this.completedCount++;
  }
  
  // 添加提醒日期相关方法
  java.util.Date getReminderDate() {
    return reminderDate;
  }
  
  void setReminderDate(java.util.Date date) {
    this.reminderDate = date;
  }
  
  // 添加判断是否有提醒日期的方法
  boolean hasReminder() {
    return reminderDate != null;
  }
  
  String getFormattedReminderDate() {
    if (reminderDate == null) return "";
    java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
    return dateFormat.format(reminderDate);
  }
} 
