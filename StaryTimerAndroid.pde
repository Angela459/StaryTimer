import processing.core.PApplet;
import android.content.Context;
import android.app.Activity;
import android.os.Bundle;
import android.view.MotionEvent;
import java.util.ArrayList;
import android.widget.Toast;

private ArrayList<StarObject> stars = new ArrayList<StarObject>();
private Timer timer;
private UI ui;
private InputHandler input;
private FileManager fileManager;
private SceneManager sceneManager;  // 添加场景管理器

// 在类的顶部声明Statistics变量
private Statistics statistics;

// 在类的顶部添加Account变量
private Account account;

// 添加BackgroundManager变量
private BackgroundManager backgroundManager;

// 添加StarManager变量
private StarManager starManager;

// 添加HistoryManager变量
private HistoryManager historyManager;

private String task = "\u5b66\u4e60"; // "学习"
private boolean isSetupMode = false;
private boolean isEditMode = false;
private boolean isHelpMode = false;
private boolean isNumericalMode = false;
private boolean isTimerMode = false;
private boolean isCountdownSetup = false;
private boolean isSelectingMode = false;
private boolean isTaskMode = false;
private boolean isPomodoroMode = false;
private boolean isAccountMode = false;
private boolean isHistoryMode = false; // 添加历史记录模式标志

private Activity activity;  // 添加 Activity 引用


// 添加星星相关变量
boolean showCompletionMessage = false;
long completionMessageStartTime = 0;
final long COMPLETION_MESSAGE_DURATION = 3000; // 显示3秒

// 添加设置图标相关变量
PImage optionIcon, editIcon, sceneIcon, helpIcon, gobackIcon;
boolean showSettingsMenu = false; // 是否显示设置菜单

// 添加帮助模式相关变量
private int helpStep = 1; // 当前显示的帮助步骤
private PImage[] helpImages = new PImage[6]; // 存储6张帮助图片

// Add these variables to track initial countdown values
private int initialCountdownHours = 0;
private int initialCountdownMinutes = 0;
private int initialCountdownSeconds = 0;

// Add these variables for the growing star in stopwatch mode
private boolean showGrowingStar = false;
private float growingStarSize = 5;
private float growingStarMaxSize = 25;
private float growingStarMinSize = 5;

// 添加以下变量到文件顶部的变量声明区域
private boolean isUIHidden = false;
private long lastInteractionTime = 0;
private final int UI_HIDE_DELAY = 5000; // 5秒不操作后隐藏UI

// 添加底部图标相关变量
PImage beginTimerIcon, taskIcon, pomodoroIcon, accountIcon, numericalIcon;

// 添加TaskManager变量声明
private TaskManager taskManager;

// 添加番茄钟相关变量
private int pomodoroState = 0; // 0=工作, 1=短休息, 2=长休息
private int completedPomodoros = 0;
public int pomodoroWorkTime = 25; // 默认25分钟工作时间
private int pomodoroShortBreakTime = 5; // 默认5分钟短休息
private int pomodoroLongBreakTime = 15; // 默认15分钟长休息
private int pomodoroLongBreakInterval = 4; // 默认每4个番茄钟后有一次长休息
private int pomodoroLoopCount = 0;  // 记录完整循环次数

// Define the interface outside the class
interface TouchCallback {
  void onTap(float x, float y);
  void onDoubleTap(float x, float y);
  void onLongPress(float x, float y);
  void onDrag(float x, float y);
}

// 添加ActivityResult回调接口
interface ActivityResultCallback {
  void handleResult(int requestCode, int resultCode, android.content.Intent data);
}

private ActivityResultCallback activityResultCallback;

// 在类的顶部声明变量区域添加
private boolean isTimerModeSelecting = false; // 是否展开计时模式选择器

@Override
public void settings() 
{
  // 使用P2D渲染器并获取真实的屏幕尺寸
  fullScreen(P2D);
  
  // 获取真实的屏幕尺寸，避免导航栏问题
  try {
    // 获取Activity和WindowManager
    Activity activity = getActivity();
    android.view.WindowManager windowManager = activity.getWindowManager();
    android.view.Display display = windowManager.getDefaultDisplay();
    
    // 使用DisplayMetrics获取真实尺寸
    android.util.DisplayMetrics realDisplayMetrics = new android.util.DisplayMetrics();
    display.getRealMetrics(realDisplayMetrics);
    
    // 打印实际屏幕尺寸，用于调试
    println("实际屏幕尺寸: " + realDisplayMetrics.widthPixels + " x " + realDisplayMetrics.heightPixels);
  } catch (Exception e) {
    println("获取屏幕尺寸时出错: " + e.getMessage());
  }
}

@Override
public void setup() 
{
  orientation(PORTRAIT);
  
  // 设置全屏模式，隐藏系统UI
  try {
    Activity activity = getActivity();
    android.view.View decorView = activity.getWindow().getDecorView();
    
    // 设置系统UI可见性标志，隐藏导航栏和状态栏
    int uiOptions = android.view.View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                  | android.view.View.SYSTEM_UI_FLAG_FULLSCREEN
                  | android.view.View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
    decorView.setSystemUiVisibility(uiOptions);
  } catch (Exception e) {
    println("设置全屏模式时出错: " + e.getMessage());
  }
  
  fileManager = new FileManager(stars, this);  // 先初始化 fileManager
  
  timer = new Timer(this, this, fileManager);  // 然后创建 timer
  timer.setTask(task);  // 设置初始任务名称
  
  ui = new UI(this);  // 传入this作为PApplet引用
  input = new InputHandler(this);  // 传入this作为PApplet引用
  input.setTouchCallback(new TouchCallback() {
    public void onTap(float x, float y) {
      handleTap(x, y);
    }
    
    public void onDoubleTap(float x, float y) {
      handleDoubleTap(x, y);
    }
    
    public void onLongPress(float x, float y) {
      handleLongPress(x, y);
    }
    
    public void onDrag(float x, float y) {
      handleDrag(x, y);
    }
  });
  
  activity = getActivity();  // 获取 Activity 引用
  
  // 初始化必要的管理器，顺序很重要
  
  // 初始化背景管理器
  backgroundManager = new BackgroundManager(this);
  
  // 初始化星星管理器（在加载星星数据前）
  starManager = new StarManager(this);
  
  // 初始化场景管理器（会加载当前场景的星星）
  sceneManager = new SceneManager(stars, fileManager, activity);
  sceneManager.initialize();
  
  // 初始化统计管理器
  statistics = new Statistics(fileManager, this, stars, sceneManager, ui);
  
  // 初始化任务管理器
  taskManager = new TaskManager(this, ui, fileManager);
  
  // 初始化账号管理器
  account = new Account(this);
  
  // 初始化历史记录管理器
  historyManager = new HistoryManager(this, ui, fileManager);
  
  // 从UI类获取图标
  optionIcon = ui.getOptionIcon();
  editIcon = ui.getEditIcon();
  sceneIcon = ui.getAddIcon();
  helpIcon = ui.getHelpIcon();
  gobackIcon = ui.getGobackIcon();
  
  // 获取底部图标
  beginTimerIcon = ui.getBeginTimerIcon();
  taskIcon = ui.getTaskIcon();
  accountIcon = ui.getAccountIcon();
  numericalIcon = ui.getNumericalIcon();
  
  // 初始化最后交互时间
  lastInteractionTime = millis();
  
  // 加载帮助图片
  for (int i = 0; i < 6; i++) {
    helpImages[i] = loadImage("step" + (i+1) + ".jpg");
    if (helpImages[i] == null) {
      println("警告: 无法加载帮助图片 step" + (i+1) + ".jpg");
    }
  }
  
  // 在setup()方法中添加计时器完成回调
  timer.setOnFinishCallback(new Runnable() {
    public void run() {
      if (timer.getMode() == TimerMode.POMODORO) {
        timer.onPomodoroFinished();
      }
    }
  });
  
  // 设置默认界面为计时器模式，使用番茄钟
  isTimerMode = true;
  timer.setMode(TimerMode.POMODORO);
  // 设置番茄钟初始状态
  pomodoroState = 0; // 工作状态
  completedPomodoros = 0;
  // 设置番茄钟时间（默认25分钟）
  timer.reset();
  timer.setCountdownDuration(0, pomodoroWorkTime, 0);
}

@Override
public void draw() 
{
  // 清除屏幕，确保每一帧开始时没有残留
  background(0);
  
  // 重置变换矩阵和样式设置，确保每帧绘制开始时的状态是干净的
  resetMatrix();
  pushStyle();
  pushMatrix();
  
  // 绘制背景和星星
  backgroundManager.drawBackground();
  
  // 创建stars集合的副本来避免并发修改异常
  ArrayList<StarObject> starsCopy = new ArrayList<StarObject>(stars);
  
  // 绘制所有星星
  for (StarObject star : starsCopy) {
    star.paint();
  }
  
  // 检查倒计时是否刚刚结束 - 在绘制UI之前处理这个逻辑
  if (timer.isJustFinished() && timer.getMode() != TimerMode.POMODORO) {
    // 生成一个新星星 - 随机位置和大小
    StarObject newStar = starManager.createStar(
      random(width * 0.1, width * 0.9),  // x位置随机，但避开边缘
      random(height * 0.1, height * 0.9),  // y位置随机，但避开边缘
      random(10, 25)  // 随机大小改为10到25像素
    );
    
    // 设置任务信息
    newStar.setTaskName(task);  // 使用当前任务名称
    
    // 计算计时时长（毫秒）
    long durationMillis = (initialCountdownHours * 3600 + initialCountdownMinutes * 60 + initialCountdownSeconds) * 1000;
    newStar.setDuration(durationMillis);
    
    // 使用FileManager添加并保存星星
    fileManager.addStar(newStar);
    stars.add(newStar);  // 确保星星也被添加到内存中的列表
    
    // 显示完成消息
    showToast("\u606d\u559c\u5b8c\u6210\uff01"); // "恭喜完成！"
    showCompletionMessage = true;
    completionMessageStartTime = System.currentTimeMillis();
    
    // 倒计时完成后自动执行"结束计时"按钮的功能
    if (timer.getMode() == TimerMode.COUNTDOWN) {
      // 重置计时器
      timer.reset();
      // 重新应用初始倒计时设置
      timer.setCountdownDuration(initialCountdownHours, initialCountdownMinutes, initialCountdownSeconds);
      // 切换到设置状态，与点击"结束计时"按钮效果一致
      isCountdownSetup = true;
    }
    
    // 重置变换矩阵，确保后续绘制不受影响
    resetMatrix();
  }
  
  // 使用互斥条件确保只绘制一种模式的UI
  if (isEditMode) {
    // 在编辑模式下，只显示编辑界面
    ui.drawMainMenu(isUIHidden, isSetupMode, isSelectingMode, 
                  isEditMode, isHelpMode, isNumericalMode, isTaskMode,
                  showSettingsMenu, input, stars, fileManager);
  }
  else if (isHelpMode) {
    // 在帮助模式下，调用handleHelpMode显示帮助信息
    handleHelpMode();
  }
  else if (isTimerMode) {
    // 在计时器模式下更新生长星星的状态
    if (timer.getMode() == TimerMode.STOPWATCH && timer.isStarted() && !timer.isPaused()) {
      showGrowingStar = true;
      // 根据计时时长增加星星大小，每分钟增加1像素，最大25像素
      float minutes = timer.getHours() * 60 + timer.getMinutes() + timer.getSeconds() / 60.0f;
      growingStarSize = constrain(growingStarMinSize + minutes, growingStarMinSize, growingStarMaxSize);
    }
    
    ui.drawTimerScreen(timer, task, isCountdownSetup, 
                     showGrowingStar, growingStarSize, growingStarMinSize, 
                     growingStarMaxSize);
  }
  else if (isTaskMode && taskManager != null) {
    // 在任务模式下，绘制任务列表
    // 先绘制顶部背景
    ui.drawTopBar(); 
    
    // 添加"任务列表"标题，与统计模式标题位置和格式一致
    fill(255);
    textAlign(CENTER, TOP);
    textSize(70);  // 更大的标题字号，从60增加到70
    PFont boldFont = ui.getBoldFont(); // 使用UI类中预加载的粗体字体
    if (boldFont != null) {
      textFont(boldFont);
    }
    text("\u4efb\u52a1\u5217\u8868", width/2, height/14); // "任务列表" - 调整位置为height/14，更靠上
    
    taskManager.drawTaskList();
    // 绘制底部导航栏，方便用户切换
    ui.drawBottomIcons();
  }
  else if (isNumericalMode && statistics != null) {
    // 在统计模式下，绘制统计界面
    // 先绘制顶部背景
    ui.drawTopBar();
    // 显示标题
    fill(255);
    textAlign(CENTER, TOP);
    textSize(70);  // 更大的标题字号，从60增加到70
    PFont boldFont = ui.getBoldFont(); // 使用UI类中预加载的粗体字体
    if (boldFont != null) {
      textFont(boldFont);
    }
    text("\u65f6\u95f4\u7edf\u8ba1", width/2, height/14); // "时间统计" - 调整位置为height/14，更靠上
    
    // 绘制饼图 - 使用更大的尺寸
    statistics.drawPieChart(width/2, height/2, min(width, height) * 0.7);  // 使用屏幕较小边的70%作为直径
    // 绘制底部导航栏，方便用户切换
    ui.drawBottomIcons();
  }
  else if (isAccountMode && account != null) {
    // 在账号模式下，绘制账号界面
    // 先绘制顶部背景
    ui.drawTopBar(); 
    // 绘制账号界面
    if (account != null) {
      account.draw();
    }
    // 绘制底部导航栏，方便用户切换
    ui.drawBottomIcons();
  }
  else if (isHistoryMode && historyManager != null) {
    // 在历史记录模式下，绘制历史记录界面
    // 先绘制顶部背景
    ui.drawTopBar(); 
    handleHistoryMode();
    // 不再绘制底部导航栏
  }
  else {
    // 如果没有激活特定模式，绘制主菜单
    ui.drawMainMenu(isUIHidden, isSetupMode, isSelectingMode, 
                  isEditMode, isHelpMode, isNumericalMode, isTaskMode,
                  showSettingsMenu, input, stars, fileManager);
  }
  
  // 在每帧结束时检查是否需要保存
  if (fileManager.isDirty()) {
    fileManager.saveStars();
  }
  
  // 恢复变换矩阵和样式设置
  popMatrix();
  popStyle();
}

@Override
public boolean surfaceTouchEvent(MotionEvent event) 
{
  // 使用InputHandler处理触摸事件
  input.handleTouchEvent(event);
  
  // 更新最后交互时间
  lastInteractionTime = millis();
  
  // 必须调用父类的surfaceTouchEvent
  return super.surfaceTouchEvent(event);
}

public void handleTap(float x, float y) {
  // 更新最后交互时间
  lastInteractionTime = millis();
  
  // 在任何模式下都检查隐藏UI按钮点击
  if (isTimerMode && ui.isHideUIButtonClicked(x, y)) {
    isUIHidden = !isUIHidden;
    return;
  }
  
  // 如果UI隐藏，点击任何位置都会显示UI
  if (isUIHidden) {
    isUIHidden = false;
    return;
  }

  // 在计时器模式下，检查任务名称编辑图标点击
  if (isTimerMode && !timer.isStarted() && ui.isTaskNameEditClicked(x, y)) {
    ui.showTaskInputDialog(task, new TaskNameCallback() {
      public void onTaskNameSet(String taskName) {
        task = taskName;
      }
    });
    return;
  }
  
  float optionIconX = ui.getOptionIconX();
  float optionIconY = ui.getOptionIconY();
  float optionIconSize = ui.getOptionIconSize();
  float menuItemHeight = ui.getMenuItemHeight();
  float menuPadding = ui.getMenuPadding();
  
  // 在任何模式下都检查设置图标点击 (除了编辑模式)
  if (!isEditMode && dist(x, y, optionIconX, optionIconY) <= optionIconSize/2) {
    // 只在计时器模式下处理option.png点击
    if (isTimerMode) {
      // 切换设置菜单显示状态
      showSettingsMenu = !showSettingsMenu;
      // 关闭计时模式选择器
      isTimerModeSelecting = false;
    } else if (isHistoryMode && historyManager.isBackButtonClicked(x, y)) {
      // 在历史模式下，点击区域同时也是返回按钮的区域，处理返回操作
      historyManager.handleBackButtonClick();
    } else if (isEditMode && dist(x, y, optionIconX, optionIconY) <= optionIconSize/2) {
      // 在编辑模式下，点击区域是返回按钮的区域，退出编辑模式
      isEditMode = false;
    }
    return;
  }
  
  // 如果在计时器模式下，检查是否点击了模式选择器
  if (isTimerMode) {
    // 如果模式选择器已展开，检查点击了哪个选项
    if (isTimerModeSelecting) {
      // 获取模式选择器的位置和尺寸
      float buttonX = width / 2;
      float buttonY = height / 14;
      float buttonHeight = 70; // 新标题高度约为70像素
      float menuWidth = width * 0.3f; // 与menu.png保持一致的宽度 (从0.4f改为0.3f)
      float menuY = buttonY + buttonHeight; // 菜单从标题底部开始
      
      int clickedOption = ui.getClickedTimerModeOption(x, y, buttonX, menuY, menuWidth);
      if (clickedOption != -1) {
        // 关闭模式选择器
        isTimerModeSelecting = false;
        
        // 应用选择的模式
        switch (clickedOption) {
          case 0: // 番茄钟
            switchToMode(TimerMode.POMODORO);
            break;
          case 1: // 正计时
            switchToMode(TimerMode.STOPWATCH);
            break;
          case 2: // 倒计时
            switchToMode(TimerMode.COUNTDOWN);
            break;
        }
        return;
      }
      
      // 点击其他区域，关闭下拉菜单
      isTimerModeSelecting = false;
      return;
    }
    
    // 检查是否点击了模式选择按钮
    if (ui.isTimerModeSelectorClicked(x, y)) {
      isTimerModeSelecting = !isTimerModeSelecting;
      // 关闭设置菜单
      showSettingsMenu = false;
      return;
    }
  }
  
  // 如果设置菜单打开，检查菜单项点击
  if (showSettingsMenu) {
    // 使用UI类的方法检测菜单项点击
    int clickedMenuItem = ui.getClickedMenuItem(x, y);
    
    switch (clickedMenuItem) {
      case 0: // 编辑
        isEditMode = true;
        showSettingsMenu = false;
        return;
      
      case 1: // 分层
        // 处理分层点击 - 调用SceneManager的场景选择对话框
        if (sceneManager != null) {
          sceneManager.showSceneSelector();
        } else {
          showToast("场景管理器未初始化");
        }
        return;
      
      case 2: // 帮助
        helpStep = 1; // 重置帮助步骤为第一步
        isHelpMode = true;
        showSettingsMenu = false;
        return;
    }
  }
  
  // 在编辑模式下只检测返回按钮点击，忽略其他所有点击
  if (isEditMode) {
    float backY = height * 0.05f; // 与UI.pde中的返回按钮Y位置保持一致
    if (ui.getGobackIcon() != null && dist(x, y, optionIconX, backY) <= optionIconSize/2) {
      isEditMode = false;
    }
    return; // 在编辑模式下，不处理其他任何点击
  }
  
  // Add help mode back button handling
  if (isHelpMode) {
    // 点击时前进到下一张帮助图片
    helpStep++;
    if (helpStep > 6) { // 如果已经显示完最后一张图片
      helpStep = 1; // 重置为第一张图片
      isHelpMode = false; // 退出帮助模式
    }
    return; // 在帮助模式下，不处理其他任何点击
  }
  
  // 在历史记录模式下检测返回按钮点击
  if (isHistoryMode) {
    // 检查返回按钮点击
    if (historyManager.isBackButtonClicked(x, y)) {
      historyManager.handleBackButtonClick();
      return;
    }
    
    // 处理删除按钮点击
    if (historyManager.handleDeleteButtonClick(x, y)) {
      return;
    }
    
    // 处理历史记录翻页按钮点击
    if (historyManager.handlePageButtonClick(x, y)) {
      return;
    }
  }
  
  // 检查底部图标点击 - 在所有界面都检查
  float bottomIconSize = ui.getBottomIconSize();
  float bottomIconY = ui.getBottomIconY();
  float iconSpacing = width / 4; // 将屏幕宽度平均分为4份
  
  // 检查任务图标点击 - 第一个位置
  if (dist(x, y, iconSpacing/2, bottomIconY + bottomIconSize/2) <= bottomIconSize/2) {
    // 清除所有模式标志
    clearAllModes();
    
    // 设置新的模式
    isTaskMode = true;
    
    // 设置任务管理器为任务模式并显示任务列表
    taskManager.setTaskMode(true);
    return;
  }
  
  // 检查开始计时图标点击 - 第二个位置
  if (dist(x, y, iconSpacing*1.5, bottomIconY + bottomIconSize/2) <= bottomIconSize/2) {
    // 清除所有模式标志
    clearAllModes();
    
    // 设置新的模式
    isTimerMode = true;
    return;
  }
  
  // 检查统计图标点击 - 第三个位置
  if (dist(x, y, iconSpacing*2.5, bottomIconY + bottomIconSize/2) <= bottomIconSize/2) {
    // 清除所有模式标志
    clearAllModes();
    
    // 设置新的模式
    isNumericalMode = true;
    
    // 加载当前场景的统计数据
    statistics.loadCurrentSceneStars();
    return;
  }
  
  // 检查账户图标点击 - 第四个位置
  if (dist(x, y, iconSpacing*3.5, bottomIconY + bottomIconSize/2) <= bottomIconSize/2) {
    // 清除所有模式标志
    clearAllModes();
    
    // 设置新的模式
    isAccountMode = true;
    return;
  }
  
  // 如果任务列表可见，处理任务列表的点击
  if (isTaskMode && taskManager != null) {
    // 检查是否点击了翻页按钮
    if (taskManager.handlePageButtonClick(x, y)) {
      return;
    }
    
    // 检查是否点击了任务项
    int clickedTaskIndex = taskManager.getClickedTaskIndex(x, y);
    if (clickedTaskIndex >= 0) {
      taskManager.selectedTaskIndex = clickedTaskIndex;
      task = taskManager.getSelectedTask().getName();
      return;
    }
  }
  
  // 主菜单界面的点击处理
  if (isSelectingMode) {
    // 检查是否点击了番茄钟按钮
    if (ui.isPomodoroTimerClicked(x, y)) {
      // 切换到番茄钟模式
      isTimerMode = true;
      timer.setMode(TimerMode.POMODORO);
      isSelectingMode = false;
      
      // 设置番茄钟初始状态
      pomodoroState = 0; // 工作状态
      completedPomodoros = 0;
      
      // 设置番茄钟时间（默认25分钟）
      timer.reset();
      timer.setCountdownDuration(0, 25, 0);
      return;
    }
    
    // 检查是否点击了正计时按钮
    if (ui.isNormalTimerClicked(x, y)) {
      isTimerMode = true;
      timer.setMode(TimerMode.STOPWATCH);
      isSelectingMode = false;
      timer.reset();
      task = "\u5b66\u4e60"; // "学习"
      return;
    }
    // 检测倒计时按钮点击
    else if (ui.isCountdownTimerClicked(x, y)) {
      isTimerMode = true;
      timer.setMode(TimerMode.COUNTDOWN);
      isSelectingMode = false;
      isCountdownSetup = true;
      task = "\u5b66\u4e60"; // "学习"
      
      // 设置默认倒计时时间（25分钟）并保存初始值
      initialCountdownHours = 0;
      initialCountdownMinutes = 25;
      initialCountdownSeconds = 0;
      timer.setCountdownDuration(0, 25, 0);
      return;
    }
  }
  else if (isTimerMode && timer.getMode() == TimerMode.STOPWATCH) {
    // 在正计时模式下
    if (ui.isTaskNameClicked(x, y) && !timer.isStarted()) {
      // 删除此处的任务名称点击处理，现在只能通过点击taskNameEdit图标修改任务名称
      return;
    }
    // 检测开始/暂停按钮点击（左侧）
    else if (ui.isStartPauseButtonClicked(x, y)) {
      if (!timer.isStarted()) {
        timer.startStopwatch();
      } else if (timer.isPaused()) {
        timer.resume();
      } else {
        timer.pause();
      }
      return;
    }
    // 检测结束按钮点击（右侧）
    else if (ui.isEndButtonClicked(x, y)) {
      if (timer.isStarted()) {
        // 如果是正计时模式且显示了生长的星星，则创建一个新的星星
        if (showGrowingStar) {
          // 生成一个新星星 - 随机位置，大小为当前生长星星的大小
          StarObject newStar = starManager.createStar(
            random(width * 0.1, width * 0.9),  // x位置随机，但避开边缘
            random(height * 0.1, height * 0.9),  // y位置随机，但避开边缘
            max(growingStarSize, 8)  // 使用当前生长星星的大小，确保不小于8
          );
          
          // 设置任务信息
          newStar.setTaskName(task);
          
          // 计算计时时长（毫秒）
          long durationMillis = (timer.getHours() * 3600 + timer.getMinutes() * 60 + timer.getSeconds()) * 1000;
          newStar.setDuration(durationMillis);
          
          // 使用FileManager添加并保存星星
          fileManager.addStar(newStar);
          stars.add(newStar);  // 确保星星也添加到内存中的列表
          
          // 只显示Toast消息，不再设置屏幕显示
          showToast("\u606d\u559c\u5b8c\u6210\uff01"); // "恭喜完成！"
          
          // 重置变换矩阵，确保后续绘制不受影响
          resetMatrix();
        }
        
        // 重置计时器和相关状态
        timer.reset();
        showGrowingStar = false;
        growingStarSize = growingStarMinSize;
      }
      
      return;
    }
  }
  else if (isTimerMode && timer.getMode() == TimerMode.COUNTDOWN) {
    // 倒计时模式的按钮处理
    if (isCountdownSetup) {
      // 检测时间显示区域点击 - 允许设置时、分、秒
      if (x >= width/2 - 200 && x <= width/2 + 200 && y >= height*2/5 + 50 && y <= height*2/5 + 150) {
        // 根据点击位置确定设置时、分还是秒
        if (x < width/2 - 70) {
          // 设置小时
          ui.showTimeInputDialog("hour", timer, new TimeInputCallback() {
            public void onTimeSet(String timeUnit, int value) {
              initialCountdownHours = value;
              timer.setCountdownDuration(initialCountdownHours, initialCountdownMinutes, initialCountdownSeconds);
            }
          });
        } else if (x >= width/2 - 70 && x <= width/2 + 70) {
          // 设置分钟
          ui.showTimeInputDialog("minute", timer, new TimeInputCallback() {
            public void onTimeSet(String timeUnit, int value) {
              initialCountdownMinutes = value;
              timer.setCountdownDuration(initialCountdownHours, initialCountdownMinutes, initialCountdownSeconds);
            }
          });
        } else {
          // 设置秒钟
          ui.showTimeInputDialog("second", timer, new TimeInputCallback() {
            public void onTimeSet(String timeUnit, int value) {
              initialCountdownSeconds = value;
              timer.setCountdownDuration(initialCountdownHours, initialCountdownMinutes, initialCountdownSeconds);
            }
          });
        }
        return;
      }
      
      // 检测任务名称点击
      if (ui.isTaskNameClicked(x, y)) {
        // 删除此处的任务名称点击处理，现在只能通过点击taskNameEdit图标修改任务名称
        return;
      }
      
      // 检测开始按钮点击（左侧）
      if (ui.isStartPauseButtonClicked(x, y)) {
        isCountdownSetup = false;
        timer.startCountdown();
        return;
      }
      
      // 检测结束按钮点击（右侧）
      if (ui.isEndButtonClicked(x, y)) {
        timer.reset();  // 先重置计时器
        isCountdownSetup = true;  // 修改为true，返回到设置状态
        return;
      }
    } else {
      // 非设置模式下的按钮处理
      // 检测开始/暂停按钮点击
      if (ui.isStartPauseButtonClicked(x, y)) {
        if (!timer.isStarted()) {
          // 开始倒计时
          timer.startCountdown();
        } else if (timer.isPaused()) {
          // 继续计时
          timer.resume();
        } else {
          // 暂停计时
          timer.pause();
        }
        return;
      }
      
      // 检测结束按钮点击（右侧）
      if (ui.isEndButtonClicked(x, y)) {
        // 重置计时器和相关状态
        timer.reset();
        // 重新应用初始倒计时设置
        timer.setCountdownDuration(initialCountdownHours, initialCountdownMinutes, initialCountdownSeconds);
        isCountdownSetup = true;  // 修改为true，返回到设置状态
        return;
      }
    }
  }
  else if (isTimerMode && timer.getMode() == TimerMode.POMODORO) {
    // 番茄钟模式
    
    // 检查任务名称点击
    if (ui.isTaskNameClicked(x, y)) {
      // 删除此处的任务名称点击处理，现在只能通过点击taskNameEdit图标修改任务名称
      return;
    }
    
    // 检测开始/暂停按钮点击
    if (ui.isStartPauseButtonClicked(x, y)) {
      if (!timer.isStarted()) {
        // 开始番茄钟计时前，根据当前状态设置正确的时间
        switch (pomodoroState) {
          case 0:  // 工作状态
            timer.setCountdownDuration(0, pomodoroWorkTime, 0);
            break;
          case 1:  // 短休息状态
            timer.setCountdownDuration(0, pomodoroShortBreakTime, 0);
            break;
          case 2:  // 长休息状态
            timer.setCountdownDuration(0, pomodoroLongBreakTime, 0);
            break;
        }
        // 开始番茄钟计时
        timer.startCountdown();
      } else if (timer.isPaused()) {
        // 继续计时
        timer.resume();
      } else {
        // 暂停计时
        timer.pause();
      }
      return;
    }
    
    // 添加结束按钮点击处理
    if (ui.isEndButtonClicked(x, y)) {
      timer.reset();
      pomodoroState = 0;
      completedPomodoros = 0;
      return;
    }

    // 检查番茄钟设置图标点击
    if (ui.isPomodoroSettingClicked(x, y)) {
      // 只有在计时器未开始时才允许修改设置
      if (timer.isStarted()) {
        showToast("\u8ba1\u65f6\u8fdb\u884c\u4e2d\uff0c\u65e0\u6cd5\u4fee\u6539\u8bbe\u7f6e"); // "计时进行中，无法修改设置"
        return;
      }
      
      activity.runOnUiThread(new Runnable() {
        public void run() {
          android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
          builder.setTitle("\u756a\u8304\u949f\u8bbe\u7f6e"); // "番茄钟设置"
          
          // 创建布局
          android.widget.LinearLayout layout = new android.widget.LinearLayout(activity);
          layout.setOrientation(android.widget.LinearLayout.VERTICAL);
          layout.setPadding(50, 30, 50, 30);
          
          // 创建番茄时长标题和输入框布局
          android.widget.TextView workLabel = new android.widget.TextView(activity);
          workLabel.setText("\u756a\u8304\u65f6\u957f"); // "番茄时长"
          workLabel.setTextSize(16);
          layout.addView(workLabel);
          
          android.widget.LinearLayout workLayout = new android.widget.LinearLayout(activity);
          workLayout.setOrientation(android.widget.LinearLayout.HORIZONTAL);
          
          final android.widget.EditText workInput = new android.widget.EditText(activity);
          workInput.setHint("\u5206\u949f"); // "分钟"
          workInput.setText("25");
          workInput.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);
          workLayout.addView(workInput);
          
          android.widget.TextView workUnit = new android.widget.TextView(activity);
          workUnit.setText("\u5206\u949f"); // "分钟"
          workUnit.setTextSize(16);
          workLayout.addView(workUnit);
          layout.addView(workLayout);
          
          // 创建短休息时长标题和输入框布局
          android.widget.TextView shortBreakLabel = new android.widget.TextView(activity);
          shortBreakLabel.setText("\u77ed\u4f11\u606f\u65f6\u957f"); // "短休息时长"
          shortBreakLabel.setTextSize(16);
          layout.addView(shortBreakLabel);
          
          android.widget.LinearLayout shortBreakLayout = new android.widget.LinearLayout(activity);
          shortBreakLayout.setOrientation(android.widget.LinearLayout.HORIZONTAL);
          
          final android.widget.EditText shortBreakInput = new android.widget.EditText(activity);
          shortBreakInput.setHint("\u5206\u949f"); // "分钟"
          shortBreakInput.setText("5");
          shortBreakInput.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);
          shortBreakLayout.addView(shortBreakInput);
          
          android.widget.TextView shortBreakUnit = new android.widget.TextView(activity);
          shortBreakUnit.setText("\u5206\u949f"); // "分钟"
          shortBreakUnit.setTextSize(16);
          shortBreakLayout.addView(shortBreakUnit);
          layout.addView(shortBreakLayout);
          
          // 创建长休息时长标题和输入框布局
          android.widget.TextView longBreakLabel = new android.widget.TextView(activity);
          longBreakLabel.setText("\u957f\u4f11\u606f\u65f6\u957f"); // "长休息时长"
          longBreakLabel.setTextSize(16);
          layout.addView(longBreakLabel);
          
          android.widget.LinearLayout longBreakLayout = new android.widget.LinearLayout(activity);
          longBreakLayout.setOrientation(android.widget.LinearLayout.HORIZONTAL);
          
          final android.widget.EditText longBreakInput = new android.widget.EditText(activity);
          longBreakInput.setHint("\u5206\u949f"); // "分钟"
          longBreakInput.setText("15");
          longBreakInput.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);
          longBreakLayout.addView(longBreakInput);
          
          android.widget.TextView longBreakUnit = new android.widget.TextView(activity);
          longBreakUnit.setText("\u5206\u949f"); // "分钟"
          longBreakUnit.setTextSize(16);
          longBreakLayout.addView(longBreakUnit);
          layout.addView(longBreakLayout);
          
          // 创建长休息间隔番茄数标题和输入框布局
          android.widget.TextView longBreakIntervalLabel = new android.widget.TextView(activity);
          longBreakIntervalLabel.setText("\u957f\u4f11\u606f\u95f4\u9694\u756a\u8304\u6570"); // "长休息间隔番茄数"
          longBreakIntervalLabel.setTextSize(16);
          layout.addView(longBreakIntervalLabel);
          
          android.widget.LinearLayout longBreakIntervalLayout = new android.widget.LinearLayout(activity);
          longBreakIntervalLayout.setOrientation(android.widget.LinearLayout.HORIZONTAL);
          
          final android.widget.EditText longBreakIntervalInput = new android.widget.EditText(activity);
          longBreakIntervalInput.setHint("\u4e2a"); // "个"
          longBreakIntervalInput.setText("4");
          longBreakIntervalInput.setInputType(android.text.InputType.TYPE_CLASS_NUMBER);
          longBreakIntervalLayout.addView(longBreakIntervalInput);
          
          android.widget.TextView longBreakIntervalUnit = new android.widget.TextView(activity);
          longBreakIntervalUnit.setText("\u4e2a"); // "个"
          longBreakIntervalUnit.setTextSize(16);
          longBreakIntervalLayout.addView(longBreakIntervalUnit);
          layout.addView(longBreakIntervalLayout);

          builder.setView(layout);

          // 添加确定和取消按钮
          builder.setPositiveButton("\u786e\u5b9a", new android.content.DialogInterface.OnClickListener() { // "确定"
            public void onClick(android.content.DialogInterface dialog, int which) {
              try {
                // 获取并验证输入值
                int workMin = Integer.parseInt(workInput.getText().toString());
                int shortBreakMin = Integer.parseInt(shortBreakInput.getText().toString());
                int longBreakMin = Integer.parseInt(longBreakInput.getText().toString());
                int longBreakIntervalCount = Integer.parseInt(longBreakIntervalInput.getText().toString());
                
                // 验证输入值的合理性
                if (workMin <= 0 || shortBreakMin <= 0 || longBreakMin <= 0 || longBreakIntervalCount <= 0) {
                  showToast("\u8bf7\u8f93\u5165\u6b63\u6570"); // "请输入正数"
                  return;
                }
                
                // 更新设置
                pomodoroWorkTime = workMin;
                pomodoroShortBreakTime = shortBreakMin;
                pomodoroLongBreakTime = longBreakMin;
                pomodoroLongBreakInterval = longBreakIntervalCount;
                
                // 如果当前正在番茄钟模式，根据当前状态更新计时器时间
                if (timer.getMode() == TimerMode.POMODORO) {
                  if (!timer.isStarted()) {  // 只在计时器未开始时更新时间
                    switch (pomodoroState) {
                      case 0:  // 工作状态
                        timer.setCountdownDuration(0, pomodoroWorkTime, 0);
                        break;
                      case 1:  // 短休息状态
                        timer.setCountdownDuration(0, pomodoroShortBreakTime, 0);
                        break;
                      case 2:  // 长休息状态
                        timer.setCountdownDuration(0, pomodoroLongBreakTime, 0);
                        break;
                    }
                  }
                }
                
                showToast("\u8bbe\u7f6e\u5df2\u4fdd\u5b58"); // "设置已保存"
                
              } catch (NumberFormatException e) {
                showToast("\u8bf7\u8f93\u5165\u6709\u6548\u6570\u5b57"); // "请输入有效数字"
              }
            }
          });
          
          builder.setNegativeButton("\u53d6\u6d88", null); // "取消"
          
          builder.show();
        }
      });
      return;
    }
  }
  
  // 如果在任务模式下，检查add图标点击
  if (isTaskMode) {
    // 使用TaskManager的方法检测add图标点击
    if (taskManager.isAddIconClicked(x, y)) {
      // 显示添加任务对话框
      taskManager.showAddTaskDialog();
      return;
    }
    
    // 其他任务模式下的点击检测...
    float addIconX = ui.getAddIconX();
    float addIconY = ui.getAddIconY();
    float addIconSize = ui.getAddIconSize();
  }

  // 在handleTap方法中添加对统计模式点击的处理
  if (isNumericalMode && statistics != null) {
    float chartDiameter = min(width, height) * 0.7;
    float chartRadius = chartDiameter / 2;
    statistics.handleClick(x, y, width/2, height/2, chartRadius);
    return;
  }

  // 如果在账号模式下，检查头像点击和按钮点击
  if (isAccountMode && account != null) {
    if (account.isAvatarClicked(x, y)) {
      account.handleAvatarClick();
      return;
    }
    
    // 检查导出按钮点击
    if (account.isExportButtonClicked(x, y)) {
      showToast("\u5f00\u59cb\u5bfc\u51fa\u6570\u636e..."); // "开始导出数据..."
      fileManager.exportDataToZip();
      return;
    }
    
    // 检查导入按钮点击
    if (account.isImportButtonClicked(x, y)) {
      showToast("\u9009\u62e9\u8981\u5bfc\u5165\u7684\u6587\u4ef6"); // "选择要导入的文件"
      fileManager.importDataFromZip(this);
      return;
    }
    
    // 检查历史记录按钮点击
    if (account.isHistoryButtonClicked(x, y)) {
      // 加载历史记录数据
      historyManager.loadHistoryRecords();
      historyManager.showHistoryList();
      // 切换到历史记录模式
      clearAllModes();
      isHistoryMode = true;
      return;
    }
    
    // 检查背景图片按钮点击
    if (account.isBackgroundButtonClicked(x, y)) {
      // 调用更换背景方法
      if (backgroundManager != null) {
        backgroundManager.changeBackground();
      }
      return;
    }
    
    // 检查星星图片按钮点击
    if (account.isStarImageButtonClicked(x, y)) {
      if (starManager != null) {
        starManager.changeStarImage();
      }
      return;
    }
  }
}

public void handleDoubleTap(float x, float y) {
  // 处理双击事件
  if (isEditMode) {
    // 检查是否点击了星星
    // 创建stars集合的副本来避免并发修改异常
    ArrayList<StarObject> starsCopy = new ArrayList<StarObject>(stars);
    for (int i = starsCopy.size() - 1; i >= 0; i--) {
      StarObject star = starsCopy.get(i);
      // 使用更大的点击区域（至少25像素）
      float clickSize = max(star.getSize(), 25);
      if (dist(x, y, star.getX(), star.getY()) < clickSize) {
        // 因为我们使用的是副本，所以需要找到原始集合中的索引
        int originalIndex = stars.indexOf(star);
        if (originalIndex >= 0) {
          // 显示星星信息对话框
          fileManager.showStarInfoDialog(originalIndex);
        }
        break;
      }
    }
  }
}

public void handleLongPress(float x, float y) {
  // 更新最后交互时间
  lastInteractionTime = millis();
}

public void handleDrag(float x, float y) {
  // 更新最后交互时间
  lastInteractionTime = millis();
  
  if (isEditMode) 
  {
    // 创建stars集合的副本来避免并发修改异常
    // 注意：为了能够修改原始集合，我们不能使用副本进行修改
    // 而是通过安全地遍历索引来操作原始集合
    synchronized(stars) {
      for (int i = 0; i < stars.size(); i++) 
      {
        StarObject star = stars.get(i);
        // 使用更大的点击区域（至少25像素）
        float clickSize = max(star.getSize(), 25);
        if (dist(x, y, star.getX(), star.getY()) < clickSize) 
        {
          // 限制星星在屏幕内
          float newX = constrain(x, star.getSize(), width - star.getSize());
          float newY = constrain(y, star.getSize(), height - star.getSize());
          
          star.setPosition(newX, newY);
          fileManager.updateStarPosition(i, newX, newY);
        }
      }
    }
  }
}

public void drawMainMenu() 
{
  // 如果UI隐藏，不绘制任何菜单元素
  if (isUIHidden) return;
  
  if (isSetupMode) 
  {
    ui.drawMenuIcons(width-width/35, 0, width/35);
    
    if (!input.isHovering(width-width/35, 0, width/35, height)) 
    {
      isSetupMode = false;
      isEditMode = false;
      isHelpMode = false;
      isNumericalMode = false;
    }
  }
  
  if (isEditMode) 
  {
    handleEditMode();
  } 
  else if (isHelpMode) 
  {
    handleHelpMode();
  } 
}

public void handleEditMode() 
{
  // 在右上角显示返回按钮
  ui.drawGoBack(ui.getOptionIconX(), ui.getOptionIconY(), ui.getOptionIconSize());
  
  // 添加提示文本
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("\u7f16\u8f91\u6a21\u5f0f: \u62d6\u52a8\u661f\u661f\u6539\u53d8\u4f4d\u7f6e, \u53cc\u51fb\u67e5\u770b\u4fe1\u606f", width/2, height - 100); // "编辑模式: 拖动星星改变位置, 双击查看信息"
  
  // 拖动逻辑保持不变
  if (input.isDragging()) 
  {
    for (int i = 0; i < stars.size(); i++) 
    {
      StarObject star = stars.get(i);
      if (input.isHovering(star.getX() - star.getSize(), star.getY() - star.getSize(), 
          star.getSize() * 2, star.getSize() * 2)) 
      {
        star.setPosition(input.getTouchX(), input.getTouchY());
        fileManager.updateStarPosition(i, input.getTouchX(), input.getTouchY());
      }
    }
  }
}

public void handleHelpMode() 
{
  // 显示当前步骤的帮助图片（全屏显示）
  if (helpImages[helpStep-1] != null) {
    imageMode(CORNER);
    image(helpImages[helpStep-1], 0, 0, width, height);
    
    // 显示当前步骤指示器
    drawStepIndicator(helpStep, 6);
    
    // 显示点击提示，使用Unicode编码
    String hintText = (helpStep < 6) ? "\u70b9\u51fb\u7ee7\u7eed" : "\u70b9\u51fb\u9000\u51fa"; // "点击继续" : "点击退出"
    fill(255);
    textAlign(CENTER, BOTTOM);
    textSize(30);
    text(hintText, width/2, height - 80);
  } else {
    // 如果图片未加载成功，显示错误信息，使用Unicode编码
    background(0);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("\u5e2e\u52a9\u56fe\u7247\u52a0\u8f7d\u5931\u8d25\uff0c\u8bf7\u70b9\u51fb\u9000\u51fa", width/2, height/2); // "帮助图片加载失败，请点击退出"
  }
}

// 绘制步骤指示器（小圆点）
private void drawStepIndicator(int currentStep, int totalSteps) {
  float dotRadius = 10;
  float spacing = 30;
  float totalWidth = (dotRadius * 2 * totalSteps) + (spacing * (totalSteps - 1));
  float startX = width/2 - totalWidth/2 + dotRadius;
  float y = height - 50;
  
  for (int i = 1; i <= totalSteps; i++) {
    if (i == currentStep) {
      // 当前步骤用白色填充
      fill(255);
    } else {
      // 其他步骤用半透明白色
      fill(255, 150);
    }
    ellipse(startX + (i-1) * (dotRadius * 2 + spacing), y, dotRadius * 2, dotRadius * 2);
  }
}

public void handleAccountMode() {
  // 不再需要绘制顶部导航栏，由draw()方法统一处理
  
  // 绘制账号界面
  if (account != null) {
    account.draw();
  }
}

public void handleNumericalMode() {
  // 不再需要绘制顶部导航栏，由draw()方法统一处理
  
  // 显示标题
  fill(255);
  textAlign(CENTER, TOP);
  textSize(70);  // 更大的标题字号，从60增加到70
  PFont boldFont = ui.getBoldFont(); // 使用UI类中预加载的粗体字体
  if (boldFont != null) {
    textFont(boldFont);
  }
  text("\u65f6\u95f4\u7edf\u8ba1", width/2, height/14); // "时间统计" - 调整位置为height/14，更靠上
  
  // 绘制饼图 - 使用更大的尺寸
  statistics.drawPieChart(width/2, height/2, min(width, height) * 0.7);  // 使用屏幕较小边的70%作为直径
}

// 修改时间输入对话框方法，使其实时更新显示
private void showTimeInputDialog(final String timeUnit) {
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
              int h = timer.getHours();
              int m = timer.getMinutes();
              int s = timer.getSeconds();
              
              switch(timeUnit) {
                case "hour":
                  h = value;
                  break;
                case "minute":
                  m = value;
                  break;
                case "second":
                  s = value;
                  break;
              }
              
              // Store the initial values
              initialCountdownHours = h;
              initialCountdownMinutes = m;
              initialCountdownSeconds = s;
              
              timer.setCountdownDuration(h, m, s);
              timer.update();  // 立即更新显示
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

// 修改为public方法
public void showToast(final String message) {
  activity.runOnUiThread(new Runnable() {
    public void run() {
      Toast.makeText(activity, message, Toast.LENGTH_SHORT).show();
    }
  });
}

public void registerActivityResult(ActivityResultCallback callback) {
  this.activityResultCallback = callback;
}

// 添加onActivityResult方法处理图片选择结果
@Override
public void onActivityResult(int requestCode, int resultCode, android.content.Intent data) {
  super.onActivityResult(requestCode, resultCode, data);
  if (activityResultCallback != null) {
    activityResultCallback.handleResult(requestCode, resultCode, data);
  }
}

// 重新初始化Account对象
public void reinitializeAccount() {
  // 重新创建Account对象以加载最新的头像
  account = new Account(this);
}

// 重新初始化场景管理器
public void reinitializeSceneManager() {
  // 重新加载场景列表
  if (sceneManager != null) {
    sceneManager.loadSceneList();
  }
}

// 重新初始化任务管理器
public void reinitializeTaskManager() {
  // 重新加载任务列表
  if (taskManager != null) {
    taskManager.loadTasks();
  }
}

// 重新初始化背景管理器
public void reinitializeBackgroundManager() {
  // 重新创建BackgroundManager对象以加载最新的背景图片
  backgroundManager = new BackgroundManager(this);
}

// 重新初始化星星管理器
public void reinitializeStarManager() {
  // 重新创建StarManager对象以加载最新的星星图片
  starManager = new StarManager(this);
}

// 切换到指定的计时模式
private void switchToMode(TimerMode newMode) {
  // 重置计时器
  timer.reset();
  
  // 设置新模式
  timer.setMode(newMode);
  
  // 根据不同模式进行初始化
  switch (newMode) {
    case POMODORO:
      // 设置番茄钟初始状态
      pomodoroState = 0; // 工作状态
      completedPomodoros = 0;
      // 设置番茄钟时间（默认25分钟）
      timer.setCountdownDuration(0, pomodoroWorkTime, 0);
      break;
      
    case STOPWATCH:
      // 重置正计时相关状态
      showGrowingStar = false;
      growingStarSize = growingStarMinSize;
      break;
      
    case COUNTDOWN:
      // 设置倒计时初始设置状态
      isCountdownSetup = true;
      // 设置默认倒计时时间（25分钟）并保存初始值
      initialCountdownHours = 0;
      initialCountdownMinutes = 25;
      initialCountdownSeconds = 0;
      timer.setCountdownDuration(0, 25, 0);
      break;
  }
}

// 添加历史记录模式的处理方法
public void handleHistoryMode() {
  // 绘制历史记录界面
  historyManager.drawHistoryList();
}

// 添加获取StarManager的方法
public StarManager getStarManager() {
  return starManager;
}

// 添加清除所有模式标志的方法
private void clearAllModes() {
  isTaskMode = false;
  isTimerMode = false;
  isNumericalMode = false;
  isAccountMode = false;
  isHistoryMode = false;
}

// 添加onResume方法，确保在应用恢复时重新应用全屏设置
@Override
public void onResume() {
  super.onResume();
  
  // 恢复时重新设置全屏模式
  try {
    // 延迟一点执行，确保窗口已完全初始化
    activity.runOnUiThread(new Runnable() {
      public void run() {
        android.os.Handler handler = new android.os.Handler();
        handler.postDelayed(new Runnable() {
          public void run() {
            android.view.View decorView = activity.getWindow().getDecorView();
            int uiOptions = android.view.View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                         | android.view.View.SYSTEM_UI_FLAG_FULLSCREEN
                         | android.view.View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
            decorView.setSystemUiVisibility(uiOptions);
          }
        }, 300); // 延迟300毫秒
      }
    });
  } catch (Exception e) {
    println("恢复全屏模式时出错: " + e.getMessage());
  }
}