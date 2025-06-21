// We'll use the existing TouchCallback interface instead of defining a new one
class InputHandler {
  private PApplet parent;
  private boolean isDragging = false;
  private boolean isMouseMoving = false;
  private int timeCount = 0;
  private final int STILL_THRESHOLD = 8;
  private float lastTouchX, lastTouchY;
  
  // 添加触控检测相关变量
  private long touchStartTime;
  private boolean isTouching = false;
  private final int LONG_PRESS_THRESHOLD = 500; // 长按阈值（毫秒）
  
  // 添加双击检测相关变量
  private long lastClickTime = 0;
  private float lastClickX = 0;
  private float lastClickY = 0;
  private final int DOUBLE_CLICK_THRESHOLD = 300; // 双击时间阈值（毫秒）
  private final int DOUBLE_CLICK_DISTANCE = 50; // 双击距离阈值（像素）
  
  private TouchCallback callback;
  
  InputHandler() {
    // 默认构造函数
  }
  
  InputHandler(PApplet parent) {
    this.parent = parent;
  }
  
  void setTouchCallback(TouchCallback callback) {
    this.callback = callback;
  }
  
  boolean handleTouchEvent(MotionEvent event) {
    int action = event.getAction();
    float x = event.getX();
    float y = event.getY();
    
    switch (action) {
      case MotionEvent.ACTION_DOWN:
        lastTouchX = x;
        lastTouchY = y;
        touchStartTime = System.currentTimeMillis();
        isTouching = true;
        onTap(x, y);
        break;
        
      case MotionEvent.ACTION_MOVE:
        if (isTouching) {
          float dx = x - lastTouchX;
          float dy = y - lastTouchY;
          if (parent != null && parent.sqrt(dx*dx + dy*dy) > 5) {
            isDragging = true;
            if (callback != null) {
              callback.onDrag(x, y);
            }
          }
        }
        onMove(x, y);
        lastTouchX = x;
        lastTouchY = y;
        break;
        
      case MotionEvent.ACTION_UP:
        long pressDuration = System.currentTimeMillis() - touchStartTime;
        if (pressDuration > LONG_PRESS_THRESHOLD) {
          if (callback != null) {
            callback.onLongPress(x, y);
          }
        } else if (pressDuration < 200) {
          // 检查是否是双击
          long currentTime = System.currentTimeMillis();
          if (currentTime - lastClickTime < DOUBLE_CLICK_THRESHOLD && 
              (parent != null ? parent.dist(x, y, lastClickX, lastClickY) : 
              Math.sqrt((x-lastClickX)*(x-lastClickX) + (y-lastClickY)*(y-lastClickY))) < DOUBLE_CLICK_DISTANCE) {
            if (callback != null) {
              callback.onDoubleTap(x, y);
            }
          } else if (callback != null) {
            callback.onTap(x, y);
          }
          
          // 更新最后一次点击信息
          lastClickTime = currentTime;
          lastClickX = x;
          lastClickY = y;
        }
        isTouching = false;
        isDragging = false;
        break;
    }
    
    return true;
  }
  
  void onTap(float x, float y) {
    lastTouchX = x;
    lastTouchY = y;
  }
  
  void onDragStart() {
    isDragging = true;
  }
  
  void onDragEnd() {
    isDragging = false;
  }
  
  void onMove(float x, float y) {
    lastTouchX = x;
    lastTouchY = y;
    isMouseMoving = true;
  }
  
  boolean isDragging() {
    return isDragging;
  }
  
  boolean isMouseMoving() {
    return isMouseMoving;
  }
  
  void resetMouseMoving() {
    isMouseMoving = false;
  }
  
  boolean isHovering(float x, float y, float w, float h) {
    return lastTouchX >= x && lastTouchX <= x + w && 
           lastTouchY >= y && lastTouchY <= y + h;
  }
  
  boolean isStillHovering(float x, float y, float w, float h) {
    if (isHovering(x, y, w, h)) {
      timeCount++;
      return timeCount >= STILL_THRESHOLD;
    } else {
      timeCount = 0;
      return false;
    }
  }
  
  void resetTimeCount() {
    timeCount = 0;
  }
  
  float getTouchX() {
    return lastTouchX;
  }
  
  float getTouchY() {
    return lastTouchY;
  }
  
  boolean isTouching() {
    return isTouching;
  }
} 
