// 添加计时器模式枚举
enum TimerMode {
  STOPWATCH,    // 正计时
  COUNTDOWN,    // 倒计时
  POMODORO      // 番茄钟
}

public class Timer {
  private StaryTimerAndroid staryTimerAndroid;
  private PApplet parent;
  private FileManager fileManager;
  private String task;
  private boolean justFinished = false;
  private TimerMode mode = TimerMode.STOPWATCH;
  private boolean isStarted = false;
  private boolean isPaused = false;
  private long startTime;
  private long pauseStartTime;
  private long totalPausedTime = 0;
  private int countdownHours = 0;
  private int countdownMinutes = 25;
  private int countdownSeconds = 0;
  private long countdownDuration;
  private Runnable onFinishCallback;
  private long duration;
  private int hours = 0;
  private int minutes = 0;
  private int seconds = 0;
  private TimerMode defaultMode = TimerMode.STOPWATCH;  // 设置默认模式
  
  public Timer(StaryTimerAndroid staryTimerAndroid, PApplet parent, FileManager fileManager) {
    this.staryTimerAndroid = staryTimerAndroid;
    this.parent = parent;
    this.fileManager = fileManager;
    this.task = "专注工作";  // 默认任务名称
    reset();
  }
  
  // 开始正计时
  public void startStopwatch() {
    startTime = System.currentTimeMillis();
    isPaused = false;
    isStarted = true;
    mode = TimerMode.STOPWATCH;
  }
  
  // 开始倒计时
  public void startCountdown() {
    startTime = System.currentTimeMillis();
    isPaused = false;
    isStarted = true;
    
    // 确保倒计时状态正确
    if (duration <= 0) {
        duration = (hours * 3600L + minutes * 60L + seconds) * 1000L;
    }
  }
  
  public void pause() {
    if (!isPaused) {
      pauseStartTime = System.currentTimeMillis();
      isPaused = true;
    }
  }
  
  public void resume() {
    if (isPaused) {
      startTime += System.currentTimeMillis() - pauseStartTime;
      isPaused = false;
    }
  }
  
  public void reset() {
    startTime = 0;
    pauseStartTime = 0;
    isPaused = false;
    isStarted = false;
    duration = 0;
    hours = 0;
    minutes = 0;
    seconds = 0;
    justFinished = false;
  }
  
  void update() {
    if (isStarted && !isPaused) {
      long currentTime = System.currentTimeMillis();
      long elapsedTime = currentTime - startTime;
      
      if (mode == TimerMode.COUNTDOWN || mode == TimerMode.POMODORO) {
        if (elapsedTime >= duration) {
          // 计时结束
          isStarted = false;
          if (mode == TimerMode.POMODORO) {
            // 番茄钟模式只触发回调
            if (onFinishCallback != null) {
              onFinishCallback.run();
            }
          } else {
            // 普通倒计时模式只设置justFinished标志，不自动重置
            // 实际的重置和UI状态更新在StaryTimerAndroid.pde的draw方法中处理
            justFinished = true;
          }
        } else {
          // 更新剩余时间
          long remainingTime = duration - elapsedTime;
          int remainingSeconds = (int)(remainingTime / 1000);
          calculateTime(remainingSeconds);
        }
      } else if (mode == TimerMode.STOPWATCH) {
        updateStopwatch();
      }
    }
  }
  
  private void updateStopwatch() {
    if (!isStarted) {
      hours = 0;
      minutes = 0;
      seconds = 0;
    } else {
      int totalSeconds = (int)((System.currentTimeMillis() - startTime) / 1000);
      calculateTime(totalSeconds);
    }
  }
  
  private void calculateTime(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    hours = totalSeconds / 3600;
    minutes = (totalSeconds % 3600) / 60;
    seconds = totalSeconds % 60;
  }
  
  void setCountdownDuration(int h, int m, int s) {
    duration = (h * 3600L + m * 60L + s) * 1000L;
    hours = h;
    minutes = m;
    seconds = s;
  }
  
  // Getters
  public boolean isPaused() { return isPaused; }
  public boolean isStarted() { return isStarted; }
  int getHours() { return hours; }
  int getMinutes() { return minutes; }
  int getSeconds() { return seconds; }
  
  // 检查倒计时是否刚刚结束
  public boolean isJustFinished() {
    if (justFinished) {
      justFinished = false;  // 重置状态，只返回一次true
      return true;
    }
    return false;
  }

  // 在番茄钟完成时调用此方法
  private void onPomodoroFinished() {
    if (pomodoroState == 0) {  // 工作阶段结束
      // 生成一个新星星 - 随机位置和大小
      StarObject newStar = staryTimerAndroid.starManager.createStar(
        parent.random(parent.width * 0.1, parent.width * 0.9),  // x位置随机，但避开边缘
        parent.random(parent.height * 0.1, parent.height * 0.9),  // y位置随机，但避开边缘
        parent.random(10, 25)  // 随机大小改为10到25像素
      );
      
      // 设置任务信息
      newStar.setTaskName(task);  // 使用当前任务名称
      
      // 计算计时时长（毫秒）
      long durationMillis = staryTimerAndroid.pomodoroWorkTime * 60 * 1000L;  // 将分钟转换为毫秒
      newStar.setDuration(durationMillis);
      
      // 使用FileManager添加并保存星星
      fileManager.addStar(newStar);
      
      // 根据完成的番茄数决定是短休息还是长休息
      if (completedPomodoros % pomodoroLongBreakInterval == pomodoroLongBreakInterval - 1) {
        // 进入长休息
        pomodoroLoopCount ++;  // 循环次数增加
        pomodoroState = 2;
        timer.setCountdownDuration(0, pomodoroLongBreakTime, 0);
        completedPomodoros++;
        justFinished = false;  // 防止在draw()中再次生成星星
      } else {
        // 进入短休息
        pomodoroState = 1;
        timer.setCountdownDuration(0, pomodoroShortBreakTime, 0);
        completedPomodoros++;
      }
    } else {  // 休息阶段结束
      // 回到工作状态
      pomodoroState = 0;
      timer.setCountdownDuration(0, pomodoroWorkTime, 0);
    }
    
    // 显示状态变化提示
    String stateText = pomodoroState == 0 ? 
      "\u5f00\u59cb\u4e13\u6ce8\u5de5\u4f5c" :  // "开始专注工作"
      (pomodoroState == 1 ? 
        "\u5f00\u59cb\u77ed\u4f11\u606f" :      // "开始短休息"
        "\u5f00\u59cb\u957f\u4f11\u606f");      // "开始长休息"
    showToast(stateText);
    
    // 自动开始下一个阶段
    timer.startCountdown();
  }
  
  // 添加新方法
  void setMode(TimerMode newMode) {
    mode = newMode;
  }
  
  TimerMode getMode() {
    return mode;
  }

  public void setOnFinishCallback(Runnable callback) {
    this.onFinishCallback = callback;
  }

  // 添加 getDuration 方法
  public long getDuration() {
    return duration;  // 返回当前设置的持续时间（毫秒）
  }

  // 添加 getStartTime 方法
  public long getStartTime() {
    return startTime;
  }

  // 添加 getPauseTime 方法
  public long getPauseTime() {
    return pauseStartTime;
  }

  // 设置任务名称的方法
  public void setTask(String task) {
    this.task = task;
  }
} 
