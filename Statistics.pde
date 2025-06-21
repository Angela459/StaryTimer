import java.util.Map;

class Statistics {
  private FileManager fileManager;
  private PApplet parent;
  private Activity activity;
  private ArrayList<StarObject> stars;
  private String currentScene;
  private SceneManager sceneManager;
  private UI ui; // 添加UI引用
  
  // 用于存储统计数据
  private HashMap<String, Long> taskDurations;  // 任务名称 -> 总时长（毫秒）
  private float totalDuration;  // 总时长（毫秒）
  private int[] pieColors;    // 饼图颜色数组

  private int selectedSlice = -1;  // 当前选中的扇形，-1表示未选中
  private ArrayList<PieSlice> pieSlices;  // 存储饼图各个扇形的信息
  
  class PieSlice {
    float startAngle;
    float endAngle;
    String taskName;
    long duration;
    float percentage;
    
    PieSlice(float startAngle, float endAngle, String taskName, long duration, float percentage) {
      this.startAngle = startAngle;
      this.endAngle = endAngle;
      this.taskName = taskName;
      this.duration = duration;
      this.percentage = percentage;
    }
    
    boolean contains(float x, float y, float centerX, float centerY, float radius) {
      // 检查点击是否在这个扇形内
      float dx = x - centerX;
      float dy = y - centerY;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance > radius) return false;
      
      float angle = atan2(dy, dx);
      if (angle < 0) angle += TWO_PI;
      
      if (startAngle <= endAngle) {
        return angle >= startAngle && angle <= endAngle;
      } else {
        return angle >= startAngle || angle <= endAngle;
      }
    }
  }

  Statistics(FileManager fileManager, PApplet parent, ArrayList<StarObject> stars, SceneManager sceneManager, UI ui) {
    this.fileManager = fileManager;
    this.parent = parent;
    this.activity = parent.getActivity();
    this.stars = stars;
    this.sceneManager = sceneManager;
    this.ui = ui; // 保存UI引用
    this.currentScene = sceneManager.getCurrentSceneName();
    this.taskDurations = new HashMap<String, Long>();
    this.pieSlices = new ArrayList<PieSlice>();
    
    // 初始化饼图颜色数组
    pieColors = new int[] {
      parent.color(255, 99, 132),   // 红色
      parent.color(54, 162, 235),   // 蓝色
      parent.color(255, 206, 86),   // 黄色
      parent.color(75, 192, 192),   // 青色
      parent.color(153, 102, 255),  // 紫色
      parent.color(255, 159, 64),   // 橙色
      parent.color(199, 199, 199),  // 灰色
      parent.color(83, 102, 255),   // 靛蓝
      parent.color(255, 99, 255),   // 粉色
      parent.color(99, 255, 132)    // 绿色
    };
  }

  // 更新当前场景
  void updateCurrentScene() {
    this.currentScene = sceneManager.getCurrentSceneName();
  }

  // 获取当前场景的文件名
  private String getCurrentSceneFileName() {
    return "scene_" + currentScene + ".json";
  }

  // 获取完整的文件路径
  private String getFullPath(String fileName) {
    try {
      java.io.File storageDir = activity.getExternalFilesDir(null);
      if (!storageDir.exists()) {
        boolean created = storageDir.mkdirs();
      }
      java.io.File file = new java.io.File(storageDir, fileName);
      return file.getAbsolutePath();
    } catch (Exception e) {
      return parent.dataPath(fileName);
    }
  }

  // 加载当前场景的星星数据进行统计
  void loadCurrentSceneStars() {
    updateCurrentScene();
    loadStarsForStatistics(getCurrentSceneFileName());
  }

  // 从JSON文件加载星星数据进行统计
  private void loadStarsForStatistics(String fileName) {
    try {
      String fullPath = getFullPath(fileName);
      
      java.io.File file = new java.io.File(fullPath);
      if (!file.exists() || !file.canRead() || file.length() == 0) {
        return;
      }

      String[] lines = loadStrings(fullPath);
      if (lines != null && lines.length > 0) {
        String jsonStr = join(lines, "");
        
        if (jsonStr == null || jsonStr.trim().isEmpty() || jsonStr.equals("null")) {
          return;
        }

        try {
          // 清空之前的统计数据
          taskDurations.clear();
          totalDuration = 0;

          JSONArray savedStars = parseJSONArray(jsonStr);
          // 统计每个任务的总时长
          for (int i = 0; i < savedStars.size(); i++) {
            JSONObject starData = savedStars.getJSONObject(i);
            String taskName = starData.getString("taskName", "未命名任务");
            long duration = starData.getLong("duration", 0);
            
            // 更新任务时长
            if (taskDurations.containsKey(taskName)) {
              taskDurations.put(taskName, taskDurations.get(taskName) + duration);
            } else {
              taskDurations.put(taskName, duration);
            }
            
            totalDuration += duration;
          }
          
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }

  // 处理点击事件
  void handleClick(float x, float y, float centerX, float centerY, float radius) {
    // 检查饼图点击
    for (int i = 0; i < pieSlices.size(); i++) {
      if (pieSlices.get(i).contains(x, y, centerX, centerY, radius)) {
        selectedSlice = (selectedSlice == i) ? -1 : i;  // 如果点击已选中的扇形，则取消选中
        break;
      }
    }
  }

  // 绘制饼图
  void drawPieChart(float x, float y, float diameter) {
    if (taskDurations.isEmpty() || totalDuration == 0) return;

    float radius = diameter / 2;
    float lastAngle = 0;
    int colorIndex = 0;
    float legendY = y + radius + 50;  // 图例移到圆盘下方
    float legendX = x - radius;  // 图例从圆盘正下方开始
    
    pieSlices.clear();  // 清空之前的扇形数据
    
    // 绘制饼图
    for (Map.Entry<String, Long> entry : taskDurations.entrySet()) {
      String taskName = entry.getKey();
      float angle = (entry.getValue() / totalDuration) * TWO_PI;
      float percentage = (entry.getValue() / totalDuration) * 100;
      
      // 保存扇形信息
      pieSlices.add(new PieSlice(lastAngle, lastAngle + angle, taskName, entry.getValue(), percentage));
      
      // 设置扇形颜色
      parent.fill(pieColors[colorIndex % pieColors.length]);
      
      // 如果是选中的扇形，稍微突出显示
      if (colorIndex == selectedSlice) {
        parent.arc(x, y, diameter * 1.1, diameter * 1.1, lastAngle, lastAngle + angle);
        
        // 在选中扇形的中心显示时间
        float midAngle = lastAngle + angle/2;
        float textX = x + cos(midAngle) * radius * 0.7;  // 在半径70%处显示
        float textY = y + sin(midAngle) * radius * 0.7;
        
        // 绘制时间文本
        parent.fill(0);  // 黑色背景
        parent.noStroke();
        parent.rectMode(CENTER);
        String timeStr = formatDuration(entry.getValue());
        parent.textSize(28);
        float textWidth = parent.textWidth(timeStr);
        parent.rect(textX, textY, textWidth + 20, 40, 10);  // 圆角矩形背景
        
        parent.fill(255);  // 白色文字
        parent.textAlign(CENTER, CENTER);
        parent.text(timeStr, textX, textY);
        parent.rectMode(CORNER);  // 恢复默认矩形模式
      } else {
        parent.arc(x, y, diameter, diameter, lastAngle, lastAngle + angle);
      }
      
      // 绘制图例
      parent.fill(pieColors[colorIndex % pieColors.length]);
      parent.rect(legendX, legendY, 25, 25);  // 图例色块
      
      // 绘制任务名称和百分比
      parent.fill(255);
      parent.textAlign(LEFT, CENTER);
      parent.textSize(24);
      parent.text(taskName + ": " + parent.nf(percentage, 0, 1) + "%", 
                 legendX + 35, legendY + 12);
      
      lastAngle += angle;
      legendX += diameter/3;  // 图例水平排列，间隔为直径的1/3
      if (legendX > x + radius - 100) {  // 如果快超出圆盘宽度，换行
        legendX = x - radius;
        legendY += 50;
      }
      colorIndex++;
    }
  }

  // 格式化时长
  private String formatDuration(long durationMillis) {
    long hours = durationMillis / (3600 * 1000);
    long minutes = (durationMillis % (3600 * 1000)) / (60 * 1000);
    return hours + "\u65f6" + minutes + "\u5206";  // "时" "分"
  }
} 