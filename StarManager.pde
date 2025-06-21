class StarManager {
  private PApplet parent;
  private Activity activity;
  private PImage starImage;  // 星星图片
  private String starImagePath;  // 星星图片文件路径
  
  StarManager(PApplet parent) {
    this.parent = parent;
    this.activity = parent.getActivity();
    loadStarImageFromSaved();
  }
  
  // 加载保存的星星图片
  public void loadStarImageFromSaved() {
    // 从固定位置加载星星图片
    java.io.File starFile = new java.io.File(activity.getExternalFilesDir(null), "star.png");
    if (starFile.exists()) {
      PImage newStarImage = parent.loadImage(starFile.getAbsolutePath());
      if (newStarImage != null) {
        starImage = newStarImage;
      } else {
        loadDefaultStarImage();
      }
    } else {
      loadDefaultStarImage();
    }
  }
  
  // 加载默认星星图片
  private void loadDefaultStarImage() {
    try {
      // 直接从data文件夹加载默认星星图片
      PImage defaultStarImage = parent.loadImage("defaultStar.png");
      
      if (defaultStarImage != null) {
        // 将默认星星设置为当前星星图片
        starImage = defaultStarImage;
        
        // 将默认星星保存到文件系统
        try {
          java.io.File storageDir = activity.getExternalFilesDir(null);
          java.io.File starFile = new java.io.File(storageDir, "star.png");
          
          // 创建一个PGraphics对象来绘制starImage
          PGraphics pg = parent.createGraphics(starImage.width, starImage.height);
          pg.beginDraw();
          pg.background(0, 0); // 透明背景
          pg.image(starImage, 0, 0);
          pg.endDraw();
          
          // 保存为文件
          pg.save(starFile.getAbsolutePath());
          
        } catch (Exception e) {
          e.printStackTrace();
          // 即使保存失败，也不影响当前会话中显示默认星星
        }
      } else {
        // 如果无法加载defaultStar.png，尝试旧的方法
        starImage = parent.loadImage("data/star.png");
        
        if (starImage == null) {
          // 如果data目录中的图像不存在，尝试从根目录加载
          starImage = parent.loadImage("star.png");
          
          if (starImage == null) {
            // 如果默认图像不存在，显示错误并尝试创建备用图像
            showToast("\u65e0\u6cd5\u52a0\u8f7d\u9ed8\u8ba4\u661f\u661f\u56fe\u7247"); // "无法加载默认星星图片"
            createFallbackStarImage();
          }
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
      // 发生异常时创建备用图像
      createFallbackStarImage();
    }
  }
  
  // 创建备用星星图像（当star.png不可用时）
  private void createFallbackStarImage() {
    int imgSize = 50; // 足够大的图像尺寸以容纳星星
    starImage = parent.createImage(imgSize, imgSize, PConstants.ARGB);
    starImage.loadPixels();
    
    // 清除图像（透明）
    for (int i = 0; i < starImage.pixels.length; i++) {
      starImage.pixels[i] = parent.color(0, 0, 0, 0); // 完全透明
    }
    
    // 绘制星星到离屏缓冲区
    PGraphics pg = parent.createGraphics(imgSize, imgSize);
    pg.beginDraw();
    pg.clear();
    pg.translate(imgSize/2, imgSize/2); // 移动到中心
    pg.fill(255);
    pg.noStroke();
    
    // 绘制一个简单的星形
    float radius1 = imgSize/4;
    float radius2 = imgSize/8;
    int npoints = 5;
    
    pg.beginShape();
    for (int i = 0; i < npoints*2; i++) {
      float angle = TWO_PI / (npoints*2) * i;
      float radius = (i % 2 == 0) ? radius1 : radius2;
      float x = cos(angle) * radius;
      float y = sin(angle) * radius;
      pg.vertex(x, y);
    }
    pg.endShape(CLOSE);
    pg.endDraw();
    
    // 将绘制的图形复制到starImage
    starImage = pg.get();
  }
  
  // 获取星星图片
  public PImage getStarImage() {
    return starImage;
  }
  
  // 处理星星图片选择
  public void changeStarImage() {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        // 创建选择对话框
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u661f\u661f\u56fe\u7247\u8bbe\u7f6e"); // "星星图片设置"
        
        // 设置选项
        final String[] options = {"\u9ed8\u8ba4\u661f\u661f", "\u81ea\u5b9a\u4e49\u661f\u661f"}; // "默认星星", "自定义星星"
        builder.setItems(options, new android.content.DialogInterface.OnClickListener() {
          public void onClick(android.content.DialogInterface dialog, int which) {
            if (which == 0) {
              // 选择默认星星图片
              loadDefaultStarImage();
              // 保存默认星星图片
              saveDefaultStarImage();
              showToast("\u5df2\u8bbe\u7f6e\u9ed8\u8ba4\u661f\u661f"); // "已设置默认星星"
              // 重新初始化星星管理器
              ((StaryTimerAndroid)parent).reinitializeStarManager();
            } else if (which == 1) {
              // 选择自定义星星图片，打开图片选择器
              openStarImagePicker();
            }
          }
        });
        
        // 显示对话框
        builder.show();
      }
    });
  }
  
  // 打开星星图片选择器
  private void openStarImagePicker() {
    android.content.Intent intent = new android.content.Intent(android.content.Intent.ACTION_PICK);
    intent.setType("image/*");
    
    try {
      activity.startActivityForResult(intent, 3); // 使用请求码3，与其他图片选择区分
      showToast("\u6b63\u5728\u5904\u7406\u661f\u661f\u56fe\u7247..."); // "正在处理星星图片..."
      
      ((StaryTimerAndroid)parent).registerActivityResult(new ActivityResultCallback() {
        public void handleResult(int requestCode, int resultCode, android.content.Intent data) {
          if (requestCode == 3 && resultCode == android.app.Activity.RESULT_OK && data != null) {
            try {
              android.net.Uri selectedImage = data.getData();
              String[] filePathColumn = { android.provider.MediaStore.Images.Media.DATA };
              android.database.Cursor cursor = activity.getContentResolver().query(selectedImage,
                  filePathColumn, null, null, null);
              
              if (cursor != null) {
                cursor.moveToFirst();
                int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
                String picturePath = cursor.getString(columnIndex);
                cursor.close();
                
                // 获取应用私有存储目录
                java.io.File storageDir = activity.getExternalFilesDir(null);
                java.io.File starFile = new java.io.File(storageDir, "star.png");
                
                // 复制选中的图片到私有目录
                java.io.InputStream in = activity.getContentResolver().openInputStream(selectedImage);
                java.io.OutputStream out = new java.io.FileOutputStream(starFile);
                byte[] buffer = new byte[1024];
                int read;
                while ((read = in.read(buffer)) != -1) {
                  out.write(buffer, 0, read);
                }
                out.flush();
                out.close();
                in.close();
                
                // 加载新星星图片
                PImage newStarImage = parent.loadImage(starFile.getAbsolutePath());
                if (newStarImage != null) {
                  starImage = newStarImage;
                  showToast("\u661f\u661f\u56fe\u7247\u66f4\u65b0\u6210\u529f"); // "星星图片更新成功"
                  
                  // 重新初始化星星管理器
                  ((StaryTimerAndroid)parent).reinitializeStarManager();
                } else {
                  showToast("\u65e0\u6cd5\u52a0\u8f7d\u9009\u62e9\u7684\u56fe\u7247"); // "无法加载选择的图片"
                }
              } else {
                showToast("\u65e0\u6cd5\u83b7\u53d6\u56fe\u7247\u4fe1\u606f"); // "无法获取图片信息"
              }
            } catch (Exception e) {
              showToast("\u52a0\u8f7d\u661f\u661f\u56fe\u7247\u5931\u8d25: " + e.getMessage()); // "加载星星图片失败"
              e.printStackTrace();
            }
          }
        }
      });
    } catch (Exception e) {
      showToast("\u65e0\u6cd5\u6253\u5f00\u56fe\u7247\u9009\u62e9\u5668"); // "无法打开图片选择器"
      e.printStackTrace();
    }
  }
  
  // 保存默认星星图片到文件
  private void saveDefaultStarImage() {
    try {
      // 直接从data文件夹加载默认星星图片
      PImage defaultStarImage = parent.loadImage("defaultStar.png");
      
      if (defaultStarImage != null) {
        // 将默认星星设置为当前星星图片
        starImage = defaultStarImage;
        
        // 保存到文件系统
        java.io.File storageDir = activity.getExternalFilesDir(null);
        java.io.File starFile = new java.io.File(storageDir, "star.png");
        
        // 创建一个PGraphics对象来绘制星星图片
        PGraphics pg = parent.createGraphics(starImage.width, starImage.height);
        pg.beginDraw();
        pg.clear(); // 使背景透明
        pg.image(starImage, 0, 0);
        pg.endDraw();
        
        // 保存为文件
        pg.save(starFile.getAbsolutePath());
      } else {
        showToast("\u65e0\u6cd5\u52a0\u8f7d\u9ed8\u8ba4\u661f\u661f\u56fe\u7247"); // "无法加载默认星星图片"
      }
    } catch (Exception e) {
      e.printStackTrace();
      showToast("\u4fdd\u5b58\u9ed8\u8ba4\u661f\u661f\u56fe\u7247\u5931\u8d25"); // "保存默认星星图片失败"
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
  
  // 创建新的星星对象
  public StarObject createStar(float x, float y, float size) {
    // 确保size不小于10
    size = max(size, 10);
    return new StarObject(x, y, size);
  }
  
  // 创建随机位置的星星对象
  public StarObject createRandomStar() {
    return new StarObject(
      parent.random(0, parent.width),  // x
      parent.random(0, parent.height), // y
      parent.random(10, 25)  // 大小范围从10到25像素
    );
  }
} 

// 星星对象类
class StarObject {
  private float x, y;
  private float size;
  
  // 闪烁相关变量
  private float originalSize;
  private float sizeOffset = 0;
  private float twinkleSpeed = 0.05;
  private float twinkleAmount = 0.3; // 闪烁幅度，0.3表示大小变化为原始大小的±30%
  
  // 添加任务相关信息
  private String taskName = "\u5b66\u4e60"; // 默认为"学习"
  private long duration = 0; // 计时时长（毫秒）
  private String date = ""; // 完成日期
  
  public StarObject() {
    this(
      random(0, width),  // x
      random(0, height),  // y
      random(10, 25)  // 大小范围改为10到25像素
    );
    
    // 设置当前日期
    setCurrentDate();
  }
  
  public StarObject(float x, float y, float size) {
    this.x = x;
    this.y = y;
    // 确保size不小于10
    this.size = max(size, 10);
    this.originalSize = max(size, 10); // 保存原始大小，同样确保最小为10
    this.twinkleSpeed = random(0.03, 0.08); // 随机闪烁速度，使每颗星星闪烁不同步
    
    // 设置当前日期
    setCurrentDate();
  }
  
  // 设置当前日期的方法
  private void setCurrentDate() {
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    this.date = sdf.format(new java.util.Date());
  }
  
  public void paint() {
    // 更新闪烁效果
    updateTwinkle();
    
    PImage starImage = ((StaryTimerAndroid)g.parent).getStarManager().getStarImage();
    if (starImage != null) {
      pushStyle(); // 保存样式设置
      pushMatrix(); // 保存变换矩阵
      
      // 设置图像模式
      imageMode(CENTER);
      
      // 移动到星星位置，不再旋转
      translate(x, y);
      
      float currentSize = size; // 当前使用的大小（受闪烁影响）
      
      // 绘制星星图片，保证1:1比例显示
      float displaySize = currentSize * 2;
      image(starImage, 0, 0, displaySize, displaySize);
      
      popMatrix(); // 恢复变换矩阵
      popStyle(); // 恢复样式设置
    }
  }
  
  // 更新闪烁效果
  private void updateTwinkle() {
    // 使用正弦函数产生平滑的大小变化
    sizeOffset += twinkleSpeed;
    float factor = 1 + sin(sizeOffset) * twinkleAmount;
    size = originalSize * factor;
  }
  
  public JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setFloat("posX", x);
    json.setFloat("posY", y);
    json.setFloat("size", originalSize); // 保存原始大小
    
    // 添加任务相关信息
    json.setString("taskName", taskName);
    json.setLong("duration", duration);
    json.setString("date", date);
    
    return json;
  }
  
  // 从JSON加载星星时设置任务信息
  public void fromJSON(JSONObject json) {
    // 加载基本属性
    if (json.hasKey("posX")) this.x = json.getFloat("posX");
    if (json.hasKey("posY")) this.y = json.getFloat("posY");
    if (json.hasKey("size")) {
      this.originalSize = json.getFloat("size");
      this.size = this.originalSize; // 确保当前大小也被设置
    }
    
    // 加载任务信息
    if (json.hasKey("taskName")) this.taskName = json.getString("taskName");
    if (json.hasKey("duration")) this.duration = json.getLong("duration");
    if (json.hasKey("date")) this.date = json.getString("date");
    
    // 打印调试信息
    println("Loaded star: " + x + ", " + y + ", size: " + size);
  }
  
  public void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  // 添加单独设置X和Y坐标的方法
  public void setX(float x) {
    this.x = x;
  }
  
  public void setY(float y) {
    this.y = y;
  }
  
  // 添加设置大小的方法
  public void setSize(float size) {
    this.originalSize = size;
    this.size = size; // 更新当前大小
  }
  
  // 设置任务信息的方法
  public void setTaskName(String taskName) {
    this.taskName = taskName;
  }
  
  public void setDuration(long duration) {
    this.duration = duration;
  }
  
  public void setDate(String date) {
    this.date = date;
  }
  
  // 获取任务信息的方法
  public String getTaskName() { 
    return taskName; 
  }
  
  public long getDuration() { 
    return duration; 
  }
  
  public String getDate() { 
    return date; 
  }
  
  public float getX() { return x; }
  public float getY() { return y; }
  public float getSize() { return originalSize; }
} 