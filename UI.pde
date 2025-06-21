class UI {
  private PFont numberFont;
  private PFont textFont;
  private PFont boldFont;
  private PImage optionImage;
  private PImage helpImage;
  private PImage editImage;
  private PImage numericalImage;
  private PImage gobackImage;
  private PImage sceneImage;
  private PImage menuBgImage; // 添加菜单背景图片
  private PImage timerModeBgImage; // 添加计时模式选择背景图片
  private Activity activity;
  private PApplet parent;

  // 添加UI相关变量
  private float optionIconX, optionIconY;
  private float optionIconSize = 216; // 修改图标大小为216，与back.png一致
  private float menuItemHeight = 110; // 菜单项高度
  private float menuWidth = 100; // 菜单宽度
  private float menuPadding = 20; // 菜单内边距

  // 添加底部图标相关的变量
  private PImage beginTimerImage, taskImage, accountImage;
  private PImage bottomBarImage; // 添加底部导航栏背景图片
  private PImage topBarImage; // 添加顶部导航栏背景图片
  private float bottomIconSize;
  private float bottomIconY;

  // 添加任务模式相关变量
  private PImage addImage;
  private float addIconSize;
  private float addIconX, addIconY;

  // 添加番茄钟设置图标相关变量
  private PImage pomodoroSettingIcon;
  
  // 添加任务名称背景图片变量
  private PImage taskNameBgImage;
  
  // 添加任务名称编辑图标变量
  private PImage taskNameEditImage;
  
  // 添加隐藏UI图标变量
  private PImage hideImage;

  UI(PApplet parent) {
    this.parent = parent;
    this.activity = ((StaryTimerAndroid)parent).getActivity();
    loadFonts();
    loadImages();
    
    // 设置图标位置到屏幕左侧，更靠近左边界
    float titleY = parent.height/14; // 标题的Y位置
    float padding = 50; // 进一步减小内边距，从80改为50，使图标更靠近左边界
    optionIconX = padding + optionIconSize/2; // 距离左边界更近
    optionIconY = titleY; // 与标题和back.png在同一水平线上
    
    // 初始化底部图标大小和位置
    bottomIconSize = parent.width / 10;
    bottomIconY = parent.height - bottomIconSize - 80;
    
    // 初始化add图标大小和位置（中心偏右上）
    addIconSize = parent.width / 8;
    addIconX = parent.width * 0.9 - addIconSize / 2;
    addIconY = parent.height * 0.21 - addIconSize / 2;

    // 加载字体
    textFont = parent.createFont("Arial", 24);
    boldFont = parent.createFont("PingFang-SC-Bold", 60); // 添加粗体字体
  }

  private void loadFonts() {
    numberFont = createFont("Algerian", 50);
  }

  private void loadImages() {
    // 移除背景图片加载，现在由BackgroundManager处理
    optionImage = loadImage("option.png");
    helpImage = loadImage("help.png");
    editImage = loadImage("edit.png");
    numericalImage = loadImage("numerical.png");
    // 不再加载gobackImage，使用相同的back.png
    sceneImage = loadImage("scene.png");
    menuBgImage = loadImage("menu.png"); // 加载菜单背景图片
    timerModeBgImage = loadImage("timerMode.png"); // 加载计时模式选择背景图片
    addImage = loadImage("add.png");  // 加载add.png
    pomodoroSettingIcon = loadImage("setting.png");  // 加载番茄钟设置图标
    // 加载底部图标
    beginTimerImage = loadImage("beginTimer.png");
    taskImage = loadImage("task.png");
    accountImage = loadImage("account.png");
    bottomBarImage = loadImage("bottomBar.png"); // 加载底部导航栏背景
    topBarImage = loadImage("topBar.png"); // 加载顶部导航栏背景
    taskNameBgImage = loadImage("taskName.png"); // 加载任务名称背景图片
    taskNameEditImage = loadImage("taskNameEdit.png"); // 加载任务名称编辑图标
    hideImage = loadImage("hide.png"); // 加载隐藏UI图标
    // 加载返回按钮图标（用于编辑模式和其他场景）
    gobackImage = loadImage("back.png"); // 使用back.png替代goback.png
  }

  void drawTime(int hours, int minutes, int seconds, float x, float y) {
    textFont(numberFont);
    textSize(50);  // 默认大小为50
    fill(255);
    textAlign(LEFT);
    text(nf(hours, 2), x, y);
    text(":", x + 57, y);
    text(nf(minutes, 2), x + 70, y);
    text(":", x + 70 + 57, y);
    text(nf(seconds, 2), x + 140, y);
  }

  // 添加新的重载方法，支持字体大小参数
  void drawTime(int hours, int minutes, int seconds, float x, float y, int size) {
    textFont(numberFont);
    textSize(size);
    fill(255);
    textAlign(LEFT);
    float digitWidth = size * 1.2;  // 根据字体大小调整间距
    text(nf(hours, 2), x, y);
    text(":", x + digitWidth, y);
    text(nf(minutes, 2), x + digitWidth * 1.3, y);
    text(":", x + digitWidth * 2.3, y);
    text(nf(seconds, 2), x + digitWidth * 2.6, y);
  }

  void drawText(String message, float x, float y, int size) {
    textFont(textFont);
    textSize(size);
    fill(255);
    textAlign(LEFT);
    text(message, x, y);
  }

  void drawCenteredText(String message, float x, float y, int size) {
    textFont(textFont);
    textSize(size);
    fill(255);
    textAlign(CENTER);
    text(message, x, y);
  }

  void drawMenuIcons(float x, float y, float size) {
    image(optionImage, x, y, size, size);
    image(helpImage, x, y + size, size, size);
    image(editImage, x, y + size * 2, size, size);
    image(numericalImage, x, y + size * 3, size, size);
  }

  void drawGoBack(float x, float y, float size) {
    parent.imageMode(CENTER);
    parent.image(gobackImage, x, y, size, size);
    parent.imageMode(CORNER); // 恢复默认imageMode
  }

  PImage getOptionIcon() {
    return optionImage;
  }
  
  PImage getEditIcon() {
    return editImage;
  }
  
  PImage getAddIcon() {
    return sceneImage;
  }
  
  PImage getHelpIcon() {
    return helpImage;
  }
  
  PImage getGobackIcon() {
    return gobackImage;
  }

  // 添加一个方法来获取底部导航栏的高度
  int getNavigationBarHeight() {
    int navigationBarHeight = 0;
    
    try {
      android.content.res.Resources resources = activity.getResources();
      int resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android");
      if (resourceId > 0) {
        navigationBarHeight = resources.getDimensionPixelSize(resourceId);
      }
    } catch (Exception e) {
      println("获取导航栏高度出错: " + e.getMessage());
    }
    
    return navigationBarHeight;
  }

  // 修改drawBottomIcons方法，确保4个图标等距分布
  void drawBottomIcons() {
    // 计算图标位置 - 4个等距图标
    float iconSpacing = parent.width / 4; // 将屏幕宽度平均分为4份
    
    // 绘制底部导航栏背景
    if (bottomBarImage != null) {
      float barWidth = parent.width;
      float barHeight = parent.width / 4; // 高度为屏幕宽度的1/4
      // 背景图触底放置
      parent.image(bottomBarImage, 0, parent.height - barHeight, barWidth, barHeight);
    }
    
    // 绘制任务图标 - 位于第一个位置
    if (taskImage != null) {
      image(taskImage, iconSpacing/2 - bottomIconSize/2, bottomIconY, bottomIconSize, bottomIconSize);
    }
    
    // 绘制开始计时图标 - 位于第二个位置
    if (beginTimerImage != null) {
      image(beginTimerImage, iconSpacing*1.5 - bottomIconSize/2, bottomIconY, bottomIconSize, bottomIconSize);
    }
    
    // 绘制统计图标 - 位于第三个位置
    if (numericalImage != null) {
      image(numericalImage, iconSpacing*2.5 - bottomIconSize/2, bottomIconY, bottomIconSize, bottomIconSize);
    }
    
    // 绘制账户图标 - 位于第四个位置
    if (accountImage != null) {
      image(accountImage, iconSpacing*3.5 - bottomIconSize/2, bottomIconY, bottomIconSize, bottomIconSize);
    }
  }
  
  // 添加绘制顶部导航栏背景的方法
  void drawTopBar() {
    if (topBarImage != null) {
      float barWidth = parent.width;
      float barHeight = parent.width * 0.3; // 高度为屏幕宽度的30%（从40%改为30%）
      parent.image(topBarImage, 0, 0, barWidth, barHeight); // 位置在最顶部
    }
  }

  void drawMainMenu(boolean isUIHidden, boolean isSetupMode, boolean isSelectingMode, 
                  boolean isEditMode, boolean isHelpMode, boolean isNumericalMode, boolean isTaskMode,
                  boolean showSettingsMenu, InputHandler input, ArrayList<StarObject> stars,
                  FileManager fileManager) {
    // 如果UI隐藏，不绘制任何菜单元素
    if (isUIHidden) {
      return;
    }
    
    // 如果在编辑模式，只显示编辑模式的UI
    if (isEditMode) {
      handleEditMode(stars, input, fileManager);
      return; // 在编辑模式下，不显示其他UI元素
    }
    
    // 只有非编辑模式才绘制顶部导航栏背景
    drawTopBar();
    
    // 始终绘制底部图标，除非在编辑模式下
    drawBottomIcons();
    
    // 如果在选择计时模式界面，绘制三个按钮
    if (isSelectingMode) {
      float menuWidth = parent.width * 0.4f; // 使选择菜单稍宽一点
      float menuHeight = 300; // 足够高以容纳三个选项
      float itemHeight = 100; // 每个选项略高一些，便于点击
      float centerX = parent.width/2;
      float centerY = parent.height/2;
      
      // 绘制菜单背景
      if (timerModeBgImage != null) {
        parent.image(timerModeBgImage, centerX - menuWidth/2, centerY - menuHeight/2, menuWidth, menuHeight);
      } else {
        // 如果没有背景图片，绘制一个半透明黑色背景
        parent.fill(40, 40, 40, 220);
        parent.stroke(255);
        parent.strokeWeight(2);
        parent.rect(centerX - menuWidth/2, centerY - menuHeight/2, menuWidth, menuHeight, 15); // 圆角矩形
      }
      
      // 绘制"选择计时模式"标题
      parent.fill(255);
      parent.textAlign(CENTER, CENTER);
      parent.textSize(40);
      parent.text("\u9009\u62e9\u8ba1\u65f6\u6a21\u5f0f", centerX, centerY - menuHeight/2 + 40); // "选择计时模式"
      
      // 绘制分隔线
      parent.stroke(150, 150);
      parent.strokeWeight(1);
      parent.line(centerX - menuWidth/2 + 20, centerY - menuHeight/2 + 80, 
                 centerX + menuWidth/2 - 20, centerY - menuHeight/2 + 80);
      
      // 绘制番茄钟按钮
      parent.fill(255, 99, 71);
      parent.textAlign(CENTER, CENTER);
      parent.textSize(36);
      parent.text("\u756a\u8304\u949f", centerX, centerY - menuHeight/6); // "番茄钟"
      
      // 绘制分隔线
      parent.stroke(150, 150);
      parent.strokeWeight(1);
      parent.line(centerX - menuWidth/2 + 20, centerY - menuHeight/6 + itemHeight/2, 
                 centerX + menuWidth/2 - 20, centerY - menuHeight/6 + itemHeight/2);
      
      // 绘制正计时按钮
      parent.fill(100, 255, 100);
      parent.text("\u6b63\u8ba1\u65f6", centerX, centerY); // "正计时"
      
      // 绘制分隔线
      parent.stroke(150, 150);
      parent.strokeWeight(1);
      parent.line(centerX - menuWidth/2 + 20, centerY + itemHeight/2, 
                 centerX + menuWidth/2 - 20, centerY + itemHeight/2);
      
      // 绘制倒计时按钮
      parent.fill(100, 100, 255);
      parent.text("\u5012\u8ba1\u65f6", centerX, centerY + menuHeight/6); // "倒计时"
    } 
    
    // 检查是否为特殊处理的模式
    if (isNumericalMode) {
      handleNumericalMode();
    }
    
    // 只在计时器模式下显示设置图标，在其他模式下不显示
    boolean isTimerMode = !isEditMode && !isTaskMode && !isHelpMode && !isNumericalMode && !isSelectingMode;
    if (isTimerMode && optionImage != null) {
      // 使用imageMode(CENTER)使图片居中显示在指定位置
      parent.imageMode(CENTER);
      parent.image(optionImage, optionIconX, optionIconY, optionIconSize, optionIconSize);
      parent.imageMode(CORNER); // 恢复默认imageMode
    }
    
    // 如果设置菜单打开，只在计时器模式下显示下拉菜单
    if (showSettingsMenu && isTimerMode) {
      // 获取菜单参数
      float menuWidth = getDropdownMenuWidth();
      float menuHeight = getDropdownMenuHeight();
      float menuItemHeight = getMenuItemHeight();
      float menuX = getDropdownMenuX();
      float menuY = getDropdownMenuY();
      
      // 绘制菜单背景
      if (menuBgImage != null) {
        parent.image(menuBgImage, menuX, menuY, menuWidth, menuHeight);
      } else {
        // 如果没有背景图片，绘制一个半透明黑色背景
        parent.fill(0, 180);
        parent.stroke(255, 100);
        parent.strokeWeight(2);
        parent.rect(menuX, menuY, menuWidth, menuHeight, 10); // 圆角矩形
      }
      
      // 绘制菜单文字
      parent.fill(255);
      parent.textAlign(CENTER, CENTER);
      parent.textFont(textFont);
      parent.textSize(36);
      
      // 绘制"编辑"菜单项，文本居中
      parent.text("\u7f16\u8f91", menuX + menuWidth/2, menuY + menuItemHeight * 0.5);
      
      // 绘制第一条分割线
      parent.stroke(150, 150);
      parent.strokeWeight(1);
      parent.line(menuX + 20, menuY + menuItemHeight, menuX + menuWidth - 20, menuY + menuItemHeight);
      
      // 绘制"分层"菜单项，文本居中
      parent.fill(255);
      parent.text("\u5206\u5c42", menuX + menuWidth/2, menuY + menuItemHeight * 1.5);
      
      // 绘制第二条分割线
      parent.stroke(150, 150);
      parent.strokeWeight(1);
      parent.line(menuX + 20, menuY + menuItemHeight * 2, menuX + menuWidth - 20, menuY + menuItemHeight * 2);
      
      // 绘制"帮助"菜单项，文本居中
      parent.fill(255);
      parent.text("\u5e2e\u52a9", menuX + menuWidth/2, menuY + menuItemHeight * 2.5);
    }
  }
  
void drawTimerScreen(Timer timer, String task, boolean isCountdownSetup, 
                    boolean showGrowingStar, float growingStarSize, 
                    float growingStarMinSize, float growingStarMaxSize) {
  // 检查是否处于编辑模式
  if (((StaryTimerAndroid)parent).isEditMode) {
    // 在编辑模式下，只绘制星星和编辑UI，这部分在drawMainMenu的handleEditMode中已处理
    return;
  }
  
  boolean isUIHidden = ((StaryTimerAndroid)parent).isUIHidden;
  
  // 注意：不再重复绘制星星，因为在StaryTimerAndroid.draw()中已经绘制过了
  
  // 如果UI未隐藏，绘制顶部导航栏和其他UI元素
  if (!isUIHidden) {
    // 绘制顶部导航栏背景
    drawTopBar();
    
    // 绘制当前模式名称和切换按钮
    String currentMode;
    
    switch (timer.getMode()) {
      case POMODORO:
        currentMode = "\u756a\u8304\u949f"; // "番茄钟"
        break;
      case STOPWATCH:
        currentMode = "\u6b63\u8ba1\u65f6"; // "正计时"
        break;
      case COUNTDOWN:
        currentMode = "\u5012\u8ba1\u65f6"; // "倒计时"
        break;
      default:
        currentMode = "\u8ba1\u65f6\u5668"; // "计时器"
        break;
    }
    
    // 绘制模式切换按钮，使用60号字体
    parent.fill(255);
    parent.textAlign(CENTER, TOP);
    parent.textFont(boldFont); // 使用UI类中预加载的粗体字体
    parent.textSize(60);  // 字体大小增加到60
    parent.text(currentMode, parent.width/2, parent.height/14); // 位置保持不变
    
    // 绘制下拉指示箭头 - 位置调整到标题正下方，并往下移动更多
    parent.fill(255);
    parent.textSize(60); // 计算文本宽度时使用与标题相同的字体大小
    float textWidth = parent.textWidth(currentMode); // 获取当前标题文本的宽度
    float arrowY = parent.height/14 + 60; // 增加到60，箭头位置进一步下移
    // 绘制朝下的三角形
    parent.triangle(
      parent.width/2, arrowY + 15, // 顶点在下方
      parent.width/2 - 15, arrowY,  // 左上角
      parent.width/2 + 15, arrowY   // 右上角
    );
    
    parent.rectMode(CORNER); // 恢复默认矩形模式
    
    // 如果当前有模式选择下拉菜单显示，绘制下拉菜单
    if (((StaryTimerAndroid)parent).isTimerModeSelecting) {
      float menuWidth = parent.width * 0.3f; // 与menu.png保持一致的宽度 (从0.4f改为0.3f)
      // 将菜单位置调整为与标题位置一致
      float titleX = parent.width/2;
      float titleY = parent.height/14;
      drawTimerModeSelector(titleX, titleY + 70, menuWidth, timer.getMode()); // 菜单位于标题下方70像素处
    }
    
    // 在模式选择按钮下方绘制隐藏UI按钮，使用hide.png图片
    if (hideImage != null) {
      float hideIconSize = 216; // 与add.png相同大小
      float hideIconX = parent.width * 0.9 - hideIconSize / 2; // 与add.png相同的X位置
      float hideIconY = parent.height / 14; // 与标题位置一致，位于height/14
      
      parent.imageMode(CENTER);
      parent.image(hideImage, hideIconX, hideIconY, hideIconSize, hideIconSize);
      parent.imageMode(CORNER);
    }
    
    // 绘制任务名称背景和任务名称
    float taskNameBgWidth = parent.width * 0.45f; // 宽度为屏幕宽度的45%
    float taskNameBgHeight = taskNameBgWidth * 0.35f; // 高度为宽度的35%（从0.32f改为0.35f）
    
    // 首先绘制背景图片
    if (taskNameBgImage != null) {
      parent.imageMode(CENTER);
      parent.image(taskNameBgImage, parent.width/2, parent.height/4, taskNameBgWidth, taskNameBgHeight);
      parent.imageMode(CORNER);
    }
    
    // 然后绘制任务名称（确保在背景之上）
    parent.fill(255);
    parent.textAlign(CENTER, CENTER);
    parent.textFont(textFont);
    parent.textSize(60);
    parent.text(task, parent.width/2, parent.height/4);
    
    // 绘制任务名称编辑图标
    if (taskNameEditImage != null && !timer.isStarted()) {
      float editIconSize = 60;  // 编辑图标大小
      float editIconX = parent.width/2 + taskNameBgWidth/2 - 80;  // 位置调整到任务名称背景的右侧但更靠左
      float editIconY = parent.height/4;  // 与任务名称同一水平线
      parent.imageMode(CENTER);
      parent.image(taskNameEditImage, editIconX, editIconY, editIconSize, editIconSize);
      parent.imageMode(CORNER);
    }
    
    // 在番茄钟模式下显示设置图标
    if (timer.getMode() == TimerMode.POMODORO && pomodoroSettingIcon != null) {
      float settingIconSize = 144;  // 设置图标大小改为144
      float settingIconX = parent.width/2 + taskNameBgWidth/2 + 20;  // 位置在任务名称右边
      if (taskNameEditImage != null && !timer.isStarted()) {
        // 如果有编辑图标，设置图标再往右移
        settingIconX += 80;
      }
      float settingIconY = parent.height/4;  // 垂直居中对齐
      parent.imageMode(CENTER);
      parent.image(pomodoroSettingIcon, settingIconX, settingIconY, settingIconSize, settingIconSize);
      parent.imageMode(CORNER);
    }
  }
  
  // 根据当前模式绘制相应界面
  switch(timer.getMode()) {
    case STOPWATCH:
      drawStopwatchScreen(timer, task, showGrowingStar, growingStarSize, isUIHidden);
      break;
    case COUNTDOWN:
      drawCountdownScreen(timer, task, isCountdownSetup, isUIHidden);
      break;
    case POMODORO:
      drawPomodoroScreen(timer, task, ((StaryTimerAndroid)parent).pomodoroState, 
                        ((StaryTimerAndroid)parent).completedPomodoros,
                        ((StaryTimerAndroid)parent).pomodoroLoopCount, isUIHidden);
      break;
  }
  
  // 如果UI未隐藏，绘制底部导航栏和设置图标
  if (!isUIHidden) {
    // 在计时器界面也绘制底部导航栏
    drawBottomIcons();
    
    // 在左侧显示设置图标
    if (optionImage != null) {
      // 使用imageMode(CENTER)使图片居中显示在指定位置
      parent.imageMode(CENTER);
      parent.image(optionImage, optionIconX, optionIconY, optionIconSize, optionIconSize);
      parent.imageMode(CORNER); // 恢复默认imageMode
    }
    
    // 如果设置菜单打开，显示下拉菜单
    if (((StaryTimerAndroid)parent).showSettingsMenu) {
      // 获取菜单参数
      float menuWidth = getDropdownMenuWidth();
      float menuHeight = getDropdownMenuHeight();
      float menuItemHeight = getMenuItemHeight();
      float menuX = getDropdownMenuX();
      float menuY = getDropdownMenuY();
      
      // 绘制菜单背景
      if (menuBgImage != null) {
        parent.image(menuBgImage, menuX, menuY, menuWidth, menuHeight);
      } else {
        // 如果没有背景图片，绘制一个半透明黑色背景
        parent.fill(0, 180);
        parent.stroke(255, 100);
        parent.strokeWeight(2);
        parent.rect(menuX, menuY, menuWidth, menuHeight, 10); // 圆角矩形
      }
      
      // 绘制菜单文字
      parent.fill(255);
      parent.textAlign(CENTER, CENTER);
      parent.textFont(textFont);
      parent.textSize(36);
      
      // 绘制"编辑"菜单项，文本居中
      parent.text("\u7f16\u8f91", menuX + menuWidth/2, menuY + menuItemHeight * 0.5);
      
      // 绘制第一条分割线
      parent.stroke(150, 150);
      parent.strokeWeight(1);
      parent.line(menuX + 20, menuY + menuItemHeight, menuX + menuWidth - 20, menuY + menuItemHeight);
      
      // 绘制"分层"菜单项，文本居中
      parent.fill(255);
      parent.text("\u5206\u5c42", menuX + menuWidth/2, menuY + menuItemHeight * 1.5);
      
      // 绘制第二条分割线
      parent.stroke(150, 150);
      parent.strokeWeight(1);
      parent.line(menuX + 20, menuY + menuItemHeight * 2, menuX + menuWidth - 20, menuY + menuItemHeight * 2);
      
      // 绘制"帮助"菜单项，文本居中
      parent.fill(255);
      parent.text("\u5e2e\u52a9", menuX + menuWidth/2, menuY + menuItemHeight * 2.5);
    }
  }
}
  
  void drawStopwatchScreen(Timer timer, String task, boolean showGrowingStar, float growingStarSize, boolean isUIHidden) {
    timer.update(); // 确保在每一帧都更新计时器状态
    
    // 在UI隐藏模式下，不显示任何UI元素
    if (!isUIHidden) {
      // 添加圆形进度条 - 每分钟转一圈（无论是否已开始计时）
      drawStopwatchProgressCircle(timer);
      
      // 在屏幕中间显示时间
      drawTime(timer.getHours(), timer.getMinutes(), timer.getSeconds(), parent.width/2 - 200, parent.height*2/5 + 100, 100);
    
      // 显示生长的星星（在UI隐藏时不显示）
      if (showGrowingStar) {
        // 创建临时星星对象并绘制（不添加到stars列表中）
        StarObject tempStar = ((StaryTimerAndroid)parent).starManager.createStar(parent.width/2, parent.height/5, growingStarSize);
        tempStar.paint();
      }
    
      // 左侧显示开始/暂停按钮 - 位置往下移
      String buttonText;
      PImage buttonImage = null;
      
      if (!timer.isStarted()) {
        buttonText = "\u5f00\u59cb\u8ba1\u65f6"; // "开始计时"
        buttonImage = loadImage("startTimer.png");
      } else if (timer.isPaused()) {
        buttonText = "\u7ee7\u7eed\u8ba1\u65f6"; // "继续计时"
        buttonImage = loadImage("startTimer.png");
      } else {
        buttonText = "\u6682\u505c\u8ba1\u65f6"; // "暂停计时"
        buttonImage = loadImage("startTimer.png");
      }
      
      // 绘制按钮背景图片
      if (buttonImage != null) {
        float buttonX = parent.width/4;
        float buttonY = parent.height*3/5;
        float buttonWidth = 313.92; // 按钮宽度调整为313.92
        float buttonHeight = 156; // 按钮高度调整为156
        parent.imageMode(CENTER);
        parent.image(buttonImage, buttonX, buttonY, buttonWidth, buttonHeight);
        parent.imageMode(CORNER);
      }
      
      // 绘制按钮文字
      parent.fill(255);
      parent.textAlign(CENTER, CENTER);
      parent.textSize(40); // 字体大小调整为40
      // 添加一个Y轴偏移使文本在背景图片中垂直居中
      float textOffsetY = 5; // 微调文本位置
      parent.text(buttonText, parent.width/4, parent.height*3/5 + textOffsetY);
      
      // 右侧显示结束按钮 - 位置往下移
      PImage endButtonImage = loadImage("pauseTimer.png");
      if (endButtonImage != null) {
        float buttonX = parent.width*3/4;
        float buttonY = parent.height*3/5;
        float buttonWidth = 313.92; // 按钮宽度调整为313.92
        float buttonHeight = 156; // 按钮高度调整为156
        parent.imageMode(CENTER);
        parent.image(endButtonImage, buttonX, buttonY, buttonWidth, buttonHeight);
        parent.imageMode(CORNER);
      }
      
      // 绘制右侧结束按钮文字
      parent.fill(255);
      parent.textAlign(CENTER, CENTER);
      parent.textSize(40); // 字体大小调整为40
      parent.text("\u7ed3\u675f\u8ba1\u65f6", parent.width*3/4, parent.height*3/5 + textOffsetY); // "结束计时"
    }
  }
  
  // 添加绘制正计时进度圆的方法 - 每分钟转一圈
  void drawStopwatchProgressCircle(Timer timer) {
    // 计算当前秒数在一分钟内的进度（0-59秒）
    int totalSeconds = timer.getSeconds() + (timer.getMinutes() % 1) * 60;
    float progress = (float)totalSeconds / 60.0f; // 每分钟的进度比例（0.0-1.0）
    
    // 设置圆的参数
    float centerX = parent.width/2;
    float centerY = parent.height*2/5 + 50; // 时间显示的中心位置
    float radius = 250; // 圆的半径，与倒计时相同
    
    // 保存当前绘图状态
    parent.pushStyle();
    
    // 设置无填充
    parent.noFill();
    
    // 绘制完整的圆（背景）- 使用较细的线条和较低的透明度
    parent.stroke(255, 100);
    parent.strokeWeight(5);
    parent.ellipse(centerX, centerY, radius*2, radius*2);
    
    // 绘制进度弧 - 使用较粗的线条和完全不透明
    parent.stroke(255);
    parent.strokeWeight(10);
    parent.strokeCap(ROUND); // 使线条末端圆滑
    
    // 计算弧的起始和结束角度（Processing中，0度在右侧，顺时针方向）
    float startAngle = -HALF_PI; // 从顶部开始（-90度）
    float endAngle = startAngle + TWO_PI * progress; // 根据进度计算结束角度
    
    // 绘制弧
    parent.arc(centerX, centerY, radius*2, radius*2, startAngle, endAngle);
    
    // 恢复之前的绘图状态
    parent.popStyle();
  }
  
  void drawCountdownScreen(Timer timer, String task, boolean isCountdownSetup, boolean isUIHidden) {
    timer.update(); // 确保在每一帧都更新计时器状态
    
    // 在UI隐藏模式下，不显示任何UI元素
    if (!isUIHidden) {
      // 绘制圆形进度条
      drawCountdownProgressCircle(timer);
      
      // 在屏幕中间显示时间
      drawTime(timer.getHours(), timer.getMinutes(), timer.getSeconds(), parent.width/2 - 200, parent.height*2/5 + 100, 100);
      
      if (isCountdownSetup) {
        // 左侧显示开始按钮 - 位置往下移
        // 绘制按钮背景图片
        PImage buttonImage = loadImage("startTimer.png");
        if (buttonImage != null) {
          float buttonX = parent.width/4;
          float buttonY = parent.height*3/5;
          float buttonWidth = 313.92; // 按钮宽度调整为313.92
          float buttonHeight = 156; // 按钮高度调整为156
          parent.imageMode(CENTER);
          parent.image(buttonImage, buttonX, buttonY, buttonWidth, buttonHeight);
          parent.imageMode(CORNER);
        }
        
        // 绘制左侧按钮文字
        parent.fill(255);
        parent.textAlign(CENTER, CENTER);
        parent.textSize(40); // 字体大小调整为40
        // 添加一个Y轴偏移使文本在背景图片中垂直居中
        float textOffsetY = 5; // 微调文本位置
        parent.text("\u5f00\u59cb\u8ba1\u65f6", parent.width/4, parent.height*3/5 + textOffsetY); // "开始计时"
        
        // 右侧结束按钮 - 绘制背景图片
        PImage endButtonImage = loadImage("pauseTimer.png");
        if (endButtonImage != null) {
          float buttonX = parent.width*3/4;
          float buttonY = parent.height*3/5;
          float buttonWidth = 313.92; // 按钮宽度调整为313.92
          float buttonHeight = 156; // 按钮高度调整为156
          parent.imageMode(CENTER);
          parent.image(endButtonImage, buttonX, buttonY, buttonWidth, buttonHeight);
          parent.imageMode(CORNER);
        }
        
        // 绘制右侧结束按钮文字
        parent.fill(255);
        parent.textAlign(CENTER, CENTER);
        parent.textSize(40); // 字体大小调整为40
        parent.text("\u7ed3\u675f\u8ba1\u65f6", parent.width*3/4, parent.height*3/5 + textOffsetY); // "结束计时"
      } else {
        // 左侧显示暂停/继续按钮 - 位置往下移
        String buttonText = timer.isPaused() ? "\u7ee7\u7eed\u8ba1\u65f6" : "\u6682\u505c\u8ba1\u65f6"; // "继续计时" : "暂停计时"
        // 绘制按钮背景图片
        PImage buttonImage = timer.isPaused() ? loadImage("startTimer.png") : loadImage("startTimer.png");
        if (buttonImage != null) {
          float buttonX = parent.width/4;
          float buttonY = parent.height*3/5;
          float buttonWidth = 313.92; // 按钮宽度调整为313.92
          float buttonHeight = 156; // 按钮高度调整为156
          parent.imageMode(CENTER);
          parent.image(buttonImage, buttonX, buttonY, buttonWidth, buttonHeight);
          parent.imageMode(CORNER);
        }
        
        // 绘制左侧按钮文字
        parent.fill(255);
        parent.textAlign(CENTER, CENTER);
        parent.textSize(40); // 字体大小调整为40
        // 添加一个Y轴偏移使文本在背景图片中垂直居中
        float textOffsetY = 5; // 微调文本位置
        parent.text(buttonText, parent.width/4, parent.height*3/5 + textOffsetY);
        
        // 右侧结束按钮 - 绘制背景图片
        PImage endButtonImage = loadImage("pauseTimer.png");
        if (endButtonImage != null) {
          float buttonX = parent.width*3/4;
          float buttonY = parent.height*3/5;
          float buttonWidth = 313.92; // 按钮宽度调整为313.92
          float buttonHeight = 156; // 按钮高度调整为156
          parent.imageMode(CENTER);
          parent.image(endButtonImage, buttonX, buttonY, buttonWidth, buttonHeight);
          parent.imageMode(CORNER);
        }
        
        // 绘制右侧结束按钮文字
        parent.fill(255);
        parent.textAlign(CENTER, CENTER);
        parent.textSize(40); // 字体大小调整为40
        parent.text("\u7ed3\u675f\u8ba1\u65f6", parent.width*3/4, parent.height*3/5 + textOffsetY); // "结束计时"
      }
    }
  }
  
  // 添加绘制倒计时进度圆的方法
  void drawCountdownProgressCircle(Timer timer) {
    // 计算总时间（毫秒）和剩余时间（毫秒）
    int initialTotalSeconds = ((StaryTimerAndroid)parent).initialCountdownHours * 3600 + 
                             ((StaryTimerAndroid)parent).initialCountdownMinutes * 60 + 
                             ((StaryTimerAndroid)parent).initialCountdownSeconds;
    
    int currentTotalSeconds = timer.getHours() * 3600 + timer.getMinutes() * 60 + timer.getSeconds();
    
    // 计算进度比例（从1到0）
    float progress = (float)currentTotalSeconds / initialTotalSeconds;
    
    // 设置圆的参数
    float centerX = parent.width/2;
    float centerY = parent.height*2/5 + 50; // 时间显示的中心位置
    float radius = 250; // 圆的半径，根据需要调整
    
    // 保存当前绘图状态
    parent.pushStyle();
    
    // 设置无填充
    parent.noFill();
    
    // 绘制完整的圆（背景）- 使用较细的线条和较低的透明度
    parent.stroke(255, 100);
    parent.strokeWeight(5);
    parent.ellipse(centerX, centerY, radius*2, radius*2);
    
    // 绘制进度弧 - 使用较粗的线条和完全不透明
    parent.stroke(255);
    parent.strokeWeight(10);
    parent.strokeCap(ROUND); // 使线条末端圆滑
    
    // 计算弧的起始和结束角度（Processing中，0度在右侧，顺时针方向）
    float startAngle = -HALF_PI; // 从顶部开始（-90度）
    float endAngle = startAngle + TWO_PI * progress; // 根据进度计算结束角度
    
    // 绘制弧
    parent.arc(centerX, centerY, radius*2, radius*2, startAngle, endAngle);
    
    // 恢复之前的绘图状态
    parent.popStyle();
  }
  
  void handleEditMode(ArrayList<StarObject> stars, InputHandler input, FileManager fileManager) {
    // 不再绘制顶部导航栏背景
    // 已删除topBar.png的绘制
    
    // 不再绘制编辑模式标题
    // 已删除标题文本
    
    // 在左上角显示返回按钮，往屏幕顶端移动
    if (gobackImage != null) {
      parent.imageMode(CENTER);
      float backY = parent.height * 0.05f; // 将Y位置移到屏幕顶部5%的位置
      parent.image(gobackImage, optionIconX, backY, optionIconSize, optionIconSize);
      parent.imageMode(CORNER);
    }
    
    // 添加提示文本
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("\u7f16\u8f91\u6a21\u5f0f: \u62d6\u52a8\u661f\u661f\u6539\u53d8\u4f4d\u7f6e, \u53cc\u51fb\u67e5\u770b\u4fe1\u606f", 
         parent.width/2, parent.height - 100); // "编辑模式: 拖动星星改变位置, 双击查看信息"
    
    // 拖动逻辑保留在StaryTimerAndroid.pde中处理
  }
  
  // handleHelpMode() function is removed since it's implemented in StaryTimerAndroid.pde
  
  void handleNumericalMode() {
    // 绘制顶部导航栏背景
    drawTopBar();
    
    // Implement numerical statistics screen
  }
  
  // 显示任务输入对话框
  void showTaskInputDialog(final String currentTask, final TaskNameCallback callback) {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u8f93\u5165\u4efb\u52a1\u540d\u79f0");  // "输入任务名称"
        
        final android.widget.EditText input = new android.widget.EditText(activity);
        input.setText(currentTask);
        builder.setView(input);
        
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() {  // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            String newTaskName = input.getText().toString();
            callback.onTaskNameSet(newTaskName);
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
  
  // 显示时间输入对话框
  void showTimeInputDialog(final String timeUnit, final Timer timer, final TimeInputCallback callback) {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        String title = "";
        final int maxValue;
        
        switch(timeUnit) {
          case "hour":
            title = "\u8bbe\u7f6e\u5c0f\u65f6";  // "设置小时"
            maxValue = 23;
            break;
          case "minute":
            title = "\u8bbe\u7f6e\u5206\u949f";  // "设置分钟"
            maxValue = 59;
            break;
          default:
            title = "\u8bbe\u7f6e\u79d2\u6570";  // "设置秒数"
            maxValue = 59;
            break;
        }
        
        builder.setTitle(title);
        
        final android.widget.EditText input = new android.widget.EditText(activity);
        input.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);
        // 显示当前值
        switch(timeUnit) {
          case "hour":
            input.setText(String.valueOf(timer.getHours()));
            break;
          case "minute":
            input.setText(String.valueOf(timer.getMinutes()));
            break;
          case "second":
            input.setText(String.valueOf(timer.getSeconds()));
            break;
        }
        builder.setView(input);
        
        builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() {  // "确定"
          public void onClick(android.content.DialogInterface dialog, int which) {
            try {
              int value = Integer.parseInt(input.getText().toString());
              if (value >= 0 && value <= maxValue) {
                callback.onTimeSet(timeUnit, value);
              }
            } catch (NumberFormatException e) {
              // 输入无效，保持原值
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
  
  // 显示完成消息
  void showCompletionToast() {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        Toast.makeText(activity, "\u606d\u559c\u5b8c\u6210\uff01", Toast.LENGTH_SHORT).show(); // "恭喜完成！"
      }
    });
  }
  
  // 获取图标位置和大小
  float getOptionIconX() { return optionIconX; }
  float getOptionIconY() { return optionIconY; }
  float getOptionIconSize() { return optionIconSize; }
  float getMenuItemHeight() { return menuItemHeight; }
  float getMenuWidth() { return menuWidth; }
  float getMenuPadding() { return menuPadding; }

  // 在UI类中添加一个方法来检查点击是否在文本区域内
  boolean isTextClicked(String text, float x, float y, float clickX, float clickY, int size) {
    textFont(textFont);
    textSize(size);
    float textWidth = textWidth(text);
    float textHeight = size;
    
    // 检查点击是否在文本区域内
    return (clickX >= x && clickX <= x + textWidth &&
            clickY >= y - textHeight && clickY <= y);
  }

  // 添加一个方法来检查主菜单中的"开始计时"按钮是否被点击
  boolean isStartTimerClicked(float clickX, float clickY) {
    String startText = "\u5f00\u59cb\u8ba1\u65f6"; // "开始计时"
    float x = parent.width/2 - 120;
    float y = parent.height/2;
    int size = 60;
    
    return isTextClicked(startText, x, y, clickX, clickY, size);
  }

  // 添加检查正计时和倒计时按钮的方法
  boolean isNormalTimerClicked(float clickX, float clickY) {
    // 如果不是在选择模式，返回false
    if (!((StaryTimerAndroid)parent).isSelectingMode) {
      return false;
    }
    
    // 使用与drawMainMenu中的选择界面一致的参数
    float menuWidth = parent.width * 0.4f;
    float menuHeight = 300;
    float itemHeight = 100;
    float centerX = parent.width/2;
    float centerY = parent.height/2;
    
    // 正计时按钮位置 - 在中间行
    float y = centerY;
    
    // 检查点击是否在菜单宽度范围内
    if (clickX < centerX - menuWidth/2 || clickX > centerX + menuWidth/2) {
      return false;
    }
    
    // 检查点击是否在正计时按钮区域内
    float topY = y - itemHeight/2;
    float bottomY = y + itemHeight/2;
    return (clickY >= topY && clickY <= bottomY);
  }

  boolean isCountdownTimerClicked(float clickX, float clickY) {
    // 如果不是在选择模式，返回false
    if (!((StaryTimerAndroid)parent).isSelectingMode) {
      return false;
    }
    
    // 使用与drawMainMenu中的选择界面一致的参数
    float menuWidth = parent.width * 0.4f;
    float menuHeight = 300;
    float itemHeight = 100;
    float centerX = parent.width/2;
    float centerY = parent.height/2;
    
    // 倒计时按钮位置 - 在底部行
    float y = centerY + menuHeight/6;
    
    // 检查点击是否在菜单宽度范围内
    if (clickX < centerX - menuWidth/2 || clickX > centerX + menuWidth/2) {
      return false;
    }
    
    // 检查点击是否在倒计时按钮区域内
    float topY = y - itemHeight/2;
    float bottomY = y + itemHeight/2;
    return (clickY >= topY && clickY <= bottomY);
  }

  // 修改按钮点击检测区域
  boolean isStartPauseButtonClicked(float clickX, float clickY) {
    // 开始/暂停按钮位置
    float x = parent.width/4;
    float y = parent.height*3/5;
    float width = 313.92;  // 与按钮图片宽度一致
    float height = 156; // 与按钮图片高度一致
    
    return (clickX >= x - width/2 && clickX <= x + width/2 &&
            clickY >= y - height/2 && clickY <= y + height/2);
  }

  boolean isEndButtonClicked(float clickX, float clickY) {
    // 结束按钮位置
    float x = parent.width*3/4;
    float y = parent.height*3/5;
    float width = 313.92;  // 与按钮图片宽度一致
    float height = 156; // 与按钮图片高度一致
    
    return (clickX >= x - width/2 && clickX <= x + width/2 &&
            clickY >= y - height/2 && clickY <= y + height/2);
  }

  // 修改任务名称点击检测区域
  boolean isTaskNameClicked(float clickX, float clickY) {
    // 任务名称位置 - 使用与绘制任务名称背景相同的尺寸
    float taskNameBgWidth = parent.width * 0.45f; // 宽度为屏幕宽度的45%
    float taskNameBgHeight = taskNameBgWidth * 0.32f; // 高度为宽度的32%
    float x = parent.width/2;
    float y = parent.height/4;
    
    // 检查点击是否在任务名称背景范围内
    return (clickX >= x - taskNameBgWidth/2 && clickX <= x + taskNameBgWidth/2 &&
            clickY >= y - taskNameBgHeight/2 && clickY <= y + taskNameBgHeight/2);
  }

  // 修正时间点击检测区域
  boolean isTimeClicked(float clickX, float clickY) {
    // 时间显示位置
    float x = parent.width/2 - 200;
    float y = parent.height*2/5 + 100;
    float width = 400;
    float height = 100;
    
    return (clickX >= x && clickX <= x + width &&
            clickY >= y - height && clickY <= y);
  }

  // 添加getter方法
  float getBottomIconSize() {
    return bottomIconSize;
  }

  float getBottomIconY() {
    return bottomIconY;
  }

  // 添加获取底部图标的方法
  PImage getBeginTimerIcon() {
    return beginTimerImage;
  }

  PImage getTaskIcon() {
    return taskImage;
  }

  PImage getAccountIcon() {
    return accountImage;
  }

  PImage getNumericalIcon() {
    return numericalImage;
  }

  // 修改drawTaskMode方法，不再绘制任务列表标题
  void drawTaskMode() {
    // 不再绘制任务列表标题，因为已经在StaryTimerAndroid.pde中绘制了
    
    // 绘制添加按钮
    if (addImage != null) {
      image(addImage, addIconX, addIconY, addIconSize, addIconSize);
    }
  }

  // 添加getter方法供StaryTimerAndroid使用
  PImage getAddImage() {
    return addImage;
  }

  float getAddIconX() {
    return addIconX;
  }

  float getAddIconY() {
    return addIconY;
  }

  float getAddIconSize() {
    return addIconSize;
  }
  
  // 添加一个获取粗体字体的方法
  PFont getBoldFont() {
    return boldFont;
  }

  // 修改番茄钟界面绘制方法
  void drawPomodoroScreen(Timer timer, String task, int pomodoroState, int completedPomodoros, int loopCount, boolean isUIHidden) {
    timer.update(); // 添加这行，确保在每一帧都更新计时器状态
    
    // 在UI隐藏模式下，不显示任何UI元素
    if (!isUIHidden) {
      // 添加圆形进度条
      float centerX = parent.width/2;
      float centerY = parent.height*2/5 + 50; // 与倒计时模式相同的Y位置
      float radius = 250; // 与倒计时模式相同的半径
      float strokeW = 10; // 与倒计时模式相同的线条粗细
      
      // 计算进度
      float progress = 0;
      if (timer.isStarted()) {
        long totalDuration = timer.getDuration();
        long elapsedTime = System.currentTimeMillis() - timer.getStartTime();
        if (timer.isPaused()) {
          elapsedTime = timer.getPauseTime() - timer.getStartTime();
        }
        progress = 1 - (float)elapsedTime / totalDuration;
        progress = constrain(progress, 0, 1);
      }
      
      // 绘制背景圆圈
      parent.noFill();
      parent.stroke(255, 100);
      parent.strokeWeight(5);
      parent.ellipse(centerX, centerY, radius*2, radius*2);
      
      // 绘制进度圆弧
      parent.stroke(getProgressColor(pomodoroState));
      parent.strokeWeight(strokeW);
      parent.strokeCap(ROUND); // 使线条末端圆滑
      parent.arc(centerX, centerY, radius*2, radius*2, -HALF_PI, -HALF_PI + TWO_PI * progress);
    
      // 在屏幕中间显示时间
      drawTime(timer.getHours(), timer.getMinutes(), timer.getSeconds(), parent.width/2 - 200, parent.height*2/5 + 100, 100);

      // 显示番茄钟状态
      String stateText = "";
      if (pomodoroState == 0) {
        stateText = "\u4e13\u6ce8\u5de5\u4f5c\u4e2d"; // "专注工作中"
      } else if (pomodoroState == 1) {
        stateText = "\u77ed\u4f11\u606f\u4e2d"; // "短休息中"
      } else if (pomodoroState == 2) {
        stateText = "\u957f\u4f11\u606f\u4e2d"; // "长休息中"
      }
      
      // 显示状态文本
      parent.fill(getProgressColor(pomodoroState));
      parent.textAlign(CENTER, CENTER);
      parent.textSize(40);
      parent.text(stateText, parent.width/2, parent.height*2/5 - 120);
      
      // 显示已完成的番茄数
      parent.fill(255);
      parent.textSize(30);
      parent.text("\u5df2\u5b8c\u6210\u5faa\u73af: " + loopCount + " \u6b21", parent.width/2, parent.height*2/5 + 200); // "已完成循环: X 次"
      
      // 左侧按钮 - 根据计时器状态显示不同文本
      String buttonText;
      PImage buttonImage = null;
      
      if (!timer.isStarted()) {
        buttonText = "\u5f00\u59cb\u8ba1\u65f6"; // "开始计时"
        buttonImage = loadImage("startTimer.png");
      } else if (timer.isPaused()) {
        buttonText = "\u7ee7\u7eed\u8ba1\u65f6"; // "继续计时"
        buttonImage = loadImage("startTimer.png");
      } else {
        buttonText = "\u6682\u505c\u8ba1\u65f6"; // "暂停计时"
        buttonImage = loadImage("startTimer.png");
      }
      
      // 左侧按钮 - 绘制背景图片
      if (buttonImage != null) {
        float buttonX = parent.width/4;
        float buttonY = parent.height*3/5;
        float buttonWidth = 313.92; // 按钮宽度调整为313.92
        float buttonHeight = 156; // 按钮高度调整为156
        parent.imageMode(CENTER);
        parent.image(buttonImage, buttonX, buttonY, buttonWidth, buttonHeight);
        parent.imageMode(CORNER);
      }
      
      // 绘制左侧按钮文字
      parent.fill(255);
      parent.textAlign(CENTER, CENTER);
      parent.textSize(40); // 字体大小调整为40
      // 添加一个Y轴偏移使文本在背景图片中垂直居中
      float textOffsetY = 5; // 微调文本位置
      parent.text(buttonText, parent.width/4, parent.height*3/5 + textOffsetY);
      
      // 右侧结束按钮 - 绘制背景图片
      PImage endButtonImage = loadImage("pauseTimer.png");
      if (endButtonImage != null) {
        float buttonX = parent.width*3/4;
        float buttonY = parent.height*3/5;
        float buttonWidth = 313.92; // 按钮宽度调整为313.92
        float buttonHeight = 156; // 按钮高度调整为156
        parent.imageMode(CENTER);
        parent.image(endButtonImage, buttonX, buttonY, buttonWidth, buttonHeight);
        parent.imageMode(CORNER);
      }
      
      // 绘制右侧结束按钮文字
      parent.fill(255);
      parent.textAlign(CENTER, CENTER);
      parent.textSize(40); // 字体大小调整为40
      parent.text("\u7ed3\u675f\u8ba1\u65f6", parent.width*3/4, parent.height*3/5 + textOffsetY); // "结束计时"
    }
  }

  // 修改番茄钟模式下结束按钮点击检测 - 位置与其他计时模式保持一致
  boolean isPomodoroEndButtonClicked(float clickX, float clickY) {
    // 番茄钟模式下结束按钮位置
    float x = parent.width*3/4;
    float y = parent.height*3/5;
    float width = 313.92;  // 与按钮图片宽度一致
    float height = 156; // 与按钮图片高度一致
    
    return (clickX >= x - width/2 && clickX <= x + width/2 &&
            clickY >= y - height/2 && clickY <= y + height/2);
  }

  // 添加番茄钟按钮点击检测方法
  boolean isPomodoroTimerClicked(float clickX, float clickY) {
    // 如果不是在选择模式，返回false
    if (!((StaryTimerAndroid)parent).isSelectingMode) {
      return false;
    }
    
    // 使用与drawMainMenu中的选择界面一致的参数
    float menuWidth = parent.width * 0.4f;
    float menuHeight = 300;
    float itemHeight = 100;
    float centerX = parent.width/2;
    float centerY = parent.height/2;
    
    // 番茄钟按钮位置 - 在第一行（菜单标题下方）
    float y = centerY - menuHeight/6;
    
    // 检查点击是否在菜单宽度范围内
    if (clickX < centerX - menuWidth/2 || clickX > centerX + menuWidth/2) {
      return false;
    }
    
    // 检查点击是否在番茄钟按钮区域内
    float topY = y - itemHeight/2;
    float bottomY = y + itemHeight/2;
    return (clickY >= topY && clickY <= bottomY);
  }

  boolean isPomodoroSettingClicked(float x, float y) {
    float taskNameBgWidth = parent.width * 0.45f;
    float settingIconSize = 144;
    float settingIconX = parent.width/2 + taskNameBgWidth/2 + 20;
    
    // 如果有编辑图标，设置图标再往右移
    if (taskNameEditImage != null && !((StaryTimerAndroid)parent).timer.isStarted()) {
      settingIconX += 80;
    }
    
    float settingIconY = parent.height/4;
    
    return dist(x, y, settingIconX, settingIconY) <= settingIconSize/2;
  }

  // 添加一个辅助方法来获取进度条颜色
  private int getProgressColor(int pomodoroState) {
    switch (pomodoroState) {
      case 0:  // 工作状态
        return parent.color(255, 99, 71); // 番茄红色
      case 1:  // 短休息状态
        return parent.color(100, 255, 100); // 绿色
      case 2:  // 长休息状态
        return parent.color(100, 100, 255); // 蓝色
      default:
        return parent.color(255); // 白色
    }
  }

  // 绘制计时模式选择下拉菜单
  void drawTimerModeSelector(float x, float y, float width, TimerMode currentMode) {
    float menuHeight = 240; // 减小菜单高度，去掉标题空间
    float itemHeight = 80; // 每个选项高度
    float menuWidth = parent.width * 0.3f; // 与menu.png保持一致的宽度
    
    // 绘制菜单背景
    if (timerModeBgImage != null) {
      parent.image(timerModeBgImage, x - menuWidth/2, y, menuWidth, menuHeight);
    } else {
      // 如果没有背景图片，绘制一个半透明黑色背景
      parent.fill(40, 40, 40, 220);
      parent.stroke(255);
      parent.strokeWeight(2);
      parent.rectMode(CENTER);
      parent.rect(x, y + menuHeight/2, menuWidth, menuHeight, 15); // 圆角矩形
      parent.rectMode(CORNER); // 恢复默认矩形模式
    }
    
    // 设置字体
    parent.textFont(textFont);
    parent.textSize(36);
    parent.textAlign(CENTER, CENTER);
    
    // 番茄钟选项
    parent.fill(255);
    parent.text("\u756a\u8304\u949f", x, y + 40); // "番茄钟"
    
    // 绘制第一条分割线
    parent.stroke(150, 150);
    parent.strokeWeight(1);
    parent.line(x - menuWidth/2 + 20, y + 80, x + menuWidth/2 - 20, y + 80);
    
    // 正计时选项
    parent.fill(255);
    parent.text("\u6b63\u8ba1\u65f6", x, y + 120); // "正计时"
    
    // 绘制第二条分割线
    parent.stroke(150, 150);
    parent.strokeWeight(1);
    parent.line(x - menuWidth/2 + 20, y + 160, x + menuWidth/2 - 20, y + 160);
    
    // 倒计时选项
    parent.fill(255);
    parent.text("\u5012\u8ba1\u65f6", x, y + 200); // "倒计时"
  }
  
  // 检查是否点击了计时模式选择按钮
  boolean isTimerModeSelectorClicked(float clickX, float clickY) {
    float buttonX = parent.width / 2;
    float buttonY = parent.height / 14;
    float clickArea = 80; // 减小点击区域以适应更小的标题
    
    // 检查点击是否在标题文本区域内，用矩形区域简化检测
    return (clickX >= buttonX - clickArea && clickX <= buttonX + clickArea &&
            clickY >= buttonY && clickY <= buttonY + 50); // 调整高度为50像素
  }
  
  // 检查点击了哪个计时模式选项（返回0=番茄钟，1=正计时，2=倒计时，-1=未点击任何选项）
  int getClickedTimerModeOption(float clickX, float clickY, float menuX, float menuY, float menuWidth) {
    // 确保使用正确的菜单宽度
    menuWidth = parent.width * 0.3f; // 与menu.png保持一致的宽度
    
    // 检查点击是否在菜单宽度范围内
    if (clickX < menuX - menuWidth/2 || clickX > menuX + menuWidth/2) {
      return -1;
    }
    
    float itemHeight = 80; // 每个选项的高度，与drawTimerModeSelector一致
    
    // 检查点击位置，直接基于菜单的y坐标计算
    // 番茄钟选项 - 顶部选项
    if (clickY >= menuY && clickY < menuY + itemHeight) {
      return 0;
    }
    // 正计时选项 - 中间选项
    else if (clickY >= menuY + itemHeight && clickY < menuY + itemHeight * 2) {
      return 1;
    }
    // 倒计时选项 - 底部选项
    else if (clickY >= menuY + itemHeight * 2 && clickY < menuY + itemHeight * 3) {
      return 2;
    }
    
    return -1;
  }

  // 检查是否点击了隐藏UI按钮
  boolean isHideUIButtonClicked(float clickX, float clickY) {
    float hideIconSize = 216;
    float hideIconX = parent.width * 0.9 - hideIconSize / 2;
    float hideIconY = parent.height / 14; // 与标题位置一致，位于height/14
    
    return dist(clickX, clickY, hideIconX, hideIconY) <= hideIconSize/2;
  }

  // 检查任务名称编辑图标是否被点击
  boolean isTaskNameEditClicked(float x, float y) {
    float taskNameBgWidth = parent.width * 0.45f;
    float editIconSize = 60;
    float editIconX = parent.width/2 + taskNameBgWidth/2 - 80;
    float editIconY = parent.height/4;
    
    return dist(x, y, editIconX, editIconY) <= editIconSize/2;
  }

  // 添加新的菜单参数方法
  float getDropdownMenuWidth() {
    return parent.width * 0.3f; // 改为屏幕宽度的30%
  }
  
  float getDropdownMenuHeight() {
    return getMenuItemHeight() * 3 + 20; // 三个菜单项的高度加上上下边距
  }
  
  float getDropdownMenuX() {
    return optionIconX - getDropdownMenuWidth()/6; // 调整菜单X坐标使其与option图标对齐
  }
  
  float getDropdownMenuY() {
    return optionIconY + optionIconSize/2 + 10; // 菜单Y坐标
  }
  
  // 检测菜单项点击的方法
  int getClickedMenuItem(float x, float y) {
    if (!((StaryTimerAndroid)parent).showSettingsMenu) {
      return -1; // 如果菜单未显示，返回-1
    }
    
    float menuX = getDropdownMenuX();
    float menuY = getDropdownMenuY();
    float menuWidth = getDropdownMenuWidth();
    float menuItemHeight = getMenuItemHeight();
    
    // 检查点击是否在菜单区域内
    if (x < menuX || x > menuX + menuWidth) {
      return -1;
    }
    
    // 确定点击了哪个菜单项
    if (y >= menuY && y < menuY + menuItemHeight) {
      return 0; // 编辑
    } else if (y >= menuY + menuItemHeight && y < menuY + menuItemHeight * 2) {
      return 1; // 分层
    } else if (y >= menuY + menuItemHeight * 2 && y < menuY + menuItemHeight * 3) {
      return 2; // 帮助
    }
    
    return -1; // 未点击任何菜单项
  }
}

// 回调接口定义
interface TaskNameCallback {
  void onTaskNameSet(String taskName);
}

interface TimeInputCallback {
  void onTimeSet(String timeUnit, int value);
}
