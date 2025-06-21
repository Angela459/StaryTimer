class Account {
  private PApplet parent;
  private Activity activity;
  private PImage avatarImage;  // 头像图片
  private float avatarX, avatarY;  // 头像位置
  private float avatarSize;  // 头像大小
  private float buttonWidth = 300;  // 按钮宽度
  private float buttonHeight = 80;  // 按钮高度
  private float buttonSpacing = 20;  // 减小按钮之间的间距，原来是40
  private float avatarButtonSpacing = 60;  // 减小头像和按钮之间的间距，原来是100
  private float importButtonY;  // 导入按钮Y坐标
  private float exportButtonY;  // 导出按钮Y坐标
  private float historyButtonY;  // 历史记录按钮Y坐标
  private float backgroundButtonY;  // 背景图片按钮Y坐标
  private float starImageButtonY;  // 星星图片按钮Y坐标
  private String avatarPath;  // 头像文件路径
  private FileManager fileManager;  // 添加FileManager引用
  private PImage homeBGImage;  // 添加背景图片变量
  
  // 添加功能按钮图标变量
  private PImage importIcon;     // 导入数据图标
  private PImage exportIcon;     // 导出数据图标
  private PImage historyIcon;    // 历史记录图标
  private PImage pictureIcon;    // 背景图片图标
  private PImage starIcon;       // 星星图片图标
  
  private float iconSize = 120;  // 图标大小
  private float iconTextSpacing = 20; // 图标和文字之间的间距
  private float rowSpacing = 300; // 增加两行图标之间的间距，从200增加到300
  
  Account(PApplet parent) {
    this.parent = parent;
    this.activity = parent.getActivity();
    this.fileManager = ((StaryTimerAndroid)parent).fileManager;
    // 加载背景图片
    this.homeBGImage = parent.loadImage("homeBG.png");
    
    // 加载功能按钮图标
    this.importIcon = parent.loadImage("import.png");
    this.exportIcon = parent.loadImage("export.png");
    this.historyIcon = parent.loadImage("history.png");
    this.pictureIcon = parent.loadImage("picture.png");
    this.starIcon = parent.loadImage("xingxing.png");
    
    parent.registerMethod("draw", this);
  }
  
  // 绘制头像和按钮
  void draw() {
    // 绘制背景图片
    if (homeBGImage != null) {
      float bgWidth = parent.width;
      float bgHeight = parent.width * 1.5f;
      // 将y坐标改为parent.height - bgHeight，使图片底部对齐屏幕底部
      parent.image(homeBGImage, 0, parent.height - bgHeight, bgWidth, bgHeight);
    }
    
    // 绘制标题 "我的"，与其他页面标题保持一致
    parent.fill(255);
    parent.textAlign(CENTER, TOP);
    parent.textSize(70);  // 与"时间统计"和"任务列表"相同的字号
    PFont boldFont = ((StaryTimerAndroid)parent).ui.getBoldFont(); // 使用UI类中预加载的粗体字体
    if (boldFont != null) {
      parent.textFont(boldFont);
    }
    parent.text("\u6211\u7684", parent.width/2, parent.height/14); // "我的" - 位置与其他标题相同，位于height/14
    
    // 第一次绘制时初始化
    if (avatarImage == null) {
      // 设置头像大小为屏幕宽度的1/4
      avatarSize = parent.width / 4;
      loadAvatarFromSaved();
      parent.unregisterMethod("draw", this);
    }
    
    // 计算头像位置 - 放置在homeBG图片的顶部中心
    float bgHeight = parent.width * 1.5f;
    float homeBGTop = parent.height - bgHeight; // homeBG图片的顶部y坐标
    
    // 头像位置设置在homeBG顶部中央，调整为更靠上的位置
    avatarX = parent.width / 2;
    avatarY = homeBGTop + parent.height * 0.02f; // 距离homeBG顶部稍微增加一点
    
    if (avatarImage != null) {
      parent.imageMode(CENTER);
      // 绘制头像边框
      parent.noFill();
      parent.stroke(255);
      parent.strokeWeight(2);
      parent.ellipse(avatarX, avatarY, avatarSize + 4, avatarSize + 4);
      
      // 绘制头像
      parent.image(avatarImage, avatarX, avatarY, avatarSize, avatarSize);
      parent.imageMode(CORNER);
    }
    
    // 计算功能按钮的起始位置 - 将按钮区域移到屏幕从下往上1/3处
    float iconsBottomY = parent.height * 2/3; // 从屏幕底部往上1/3处
    
    // 计算第二行（下面一行）两个图标的位置
    float bottomRowY = iconsBottomY;
    float fourthIconX = parent.width * 0.35f;
    float fifthIconX = parent.width * 0.65f;
    
    // 计算第一行（上面一行）三个图标的位置
    float topRowY = bottomRowY - rowSpacing; // 使用更大的行间距
    float firstIconX = parent.width * 0.2f;
    float secondIconX = parent.width * 0.5f;
    float thirdIconX = parent.width * 0.8f;
    
    // 绘制第一行三个图标（导入数据、历史记录、导出数据）
    drawIconButton(importIcon, firstIconX, topRowY, "\u5bfc\u5165\u6570\u636e"); // "导入数据"
    drawIconButton(historyIcon, secondIconX, topRowY, "\u5386\u53f2\u8bb0\u5f55"); // "历史记录"
    drawIconButton(exportIcon, thirdIconX, topRowY, "\u5bfc\u51fa\u6570\u636e"); // "导出数据"
    
    // 绘制第二行两个图标（背景图片、星星图片）
    drawIconButton(pictureIcon, fourthIconX, bottomRowY, "\u80cc\u666f\u56fe\u7247"); // "背景图片"
    drawIconButton(starIcon, fifthIconX, bottomRowY, "\u661f\u661f\u56fe\u7247"); // "星星图片"
    
    // 保存按钮位置用于点击检测
    importButtonY = topRowY;
    historyButtonY = topRowY;
    exportButtonY = topRowY;
    backgroundButtonY = bottomRowY;
    starImageButtonY = bottomRowY;
  }
  
  // 绘制图标按钮
  private void drawIconButton(PImage icon, float x, float y, String text) {
    parent.pushStyle();
    
    // 绘制图标
    if (icon != null) {
      parent.imageMode(CENTER);
      parent.image(icon, x, y, iconSize, iconSize);
      parent.imageMode(CORNER);
    }
    
    // 绘制文字
    parent.fill(255);
    parent.textAlign(CENTER, CENTER);
    parent.textSize(36);
    parent.text(text, x, y + iconSize/2 + iconTextSpacing);
    
    parent.popStyle();
  }
  
  // 检查是否有历史数据
  private boolean hasHistoricalData() {
    // 获取当前场景名称
    String currentScene = ((StaryTimerAndroid)parent).sceneManager.getCurrentSceneName();
    String fileName = "scene_" + currentScene + ".json";
    
    try {
      java.io.File storageDir = activity.getExternalFilesDir(null);
      java.io.File file = new java.io.File(storageDir, fileName);
      
      // 如果文件存在且不为空，则认为有历史数据
      return file.exists() && file.length() > 0;
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
  
  // 更新点击检测方法
  boolean isImportButtonClicked(float x, float y) {
    float iconX = parent.width * 0.2f;
    return dist(x, y, iconX, importButtonY) <= iconSize/2 || 
           (x >= iconX - iconSize/2 && x <= iconX + iconSize/2 && 
            y >= importButtonY + iconSize/2 && y <= importButtonY + iconSize/2 + iconTextSpacing + 40);
  }
  
  boolean isExportButtonClicked(float x, float y) {
    float iconX = parent.width * 0.8f;
    return dist(x, y, iconX, exportButtonY) <= iconSize/2 || 
           (x >= iconX - iconSize/2 && x <= iconX + iconSize/2 && 
            y >= exportButtonY + iconSize/2 && y <= exportButtonY + iconSize/2 + iconTextSpacing + 40);
  }
  
  boolean isHistoryButtonClicked(float x, float y) {
    // 只有当按钮显示时才检测点击
    if (hasHistoricalData()) {
      float iconX = parent.width * 0.5f;
      return dist(x, y, iconX, historyButtonY) <= iconSize/2 || 
             (x >= iconX - iconSize/2 && x <= iconX + iconSize/2 && 
              y >= historyButtonY + iconSize/2 && y <= historyButtonY + iconSize/2 + iconTextSpacing + 40);
    }
    return false;
  }
  
  boolean isBackgroundButtonClicked(float x, float y) {
    float iconX = parent.width * 0.35f;
    return dist(x, y, iconX, backgroundButtonY) <= iconSize/2 || 
           (x >= iconX - iconSize/2 && x <= iconX + iconSize/2 && 
            y >= backgroundButtonY + iconSize/2 && y <= backgroundButtonY + iconSize/2 + iconTextSpacing + 40);
  }
  
  boolean isStarImageButtonClicked(float x, float y) {
    float iconX = parent.width * 0.65f;
    return dist(x, y, iconX, starImageButtonY) <= iconSize/2 || 
           (x >= iconX - iconSize/2 && x <= iconX + iconSize/2 && 
            y >= starImageButtonY + iconSize/2 && y <= starImageButtonY + iconSize/2 + iconTextSpacing + 40);
  }
  
  // 处理头像点击
  void handleAvatarClick() {
    // 获取当前头像位置（因为位置可能会在draw()中更新）
    float bgHeight = parent.width * 1.5f;
    float homeBGTop = parent.height - bgHeight;
    avatarX = parent.width / 2;
    avatarY = homeBGTop + parent.height * 0.02f;
    
    activity.runOnUiThread(new Runnable() {
      public void run() {
        // 创建选择对话框
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u5934\u50cf\u8bbe\u7f6e"); // "头像设置"
        
        // 设置选项
        final String[] options = {"\u9ed8\u8ba4\u5934\u50cf", "\u81ea\u5b9a\u4e49\u5934\u50cf"}; // "默认头像", "自定义头像"
        builder.setItems(options, new android.content.DialogInterface.OnClickListener() {
          public void onClick(android.content.DialogInterface dialog, int which) {
            if (which == 0) {
              // 选择默认头像
              loadDefaultAvatar();
              showToast("\u5df2\u8bbe\u7f6e\u9ed8\u8ba4\u5934\u50cf"); // "已设置默认头像"
            } else if (which == 1) {
              // 选择自定义头像，打开图片选择器
              openImagePicker();
            }
          }
        });
        
        // 显示对话框
        builder.show();
      }
    });
  }
  
  // 打开图片选择器
  private void openImagePicker() {
    android.content.Intent intent = new android.content.Intent(android.content.Intent.ACTION_PICK);
    intent.setType("image/*");
    
    try {
      activity.startActivityForResult(intent, 1);
      
      ((StaryTimerAndroid)parent).registerActivityResult(new ActivityResultCallback() {
        public void handleResult(int requestCode, int resultCode, android.content.Intent data) {
          if (requestCode == 1 && resultCode == android.app.Activity.RESULT_OK && data != null) {
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
                java.io.File avatarFile = new java.io.File(storageDir, "avatar.jpg");
                
                // 复制选中的图片到私有目录
                java.io.InputStream in = activity.getContentResolver().openInputStream(selectedImage);
                java.io.OutputStream out = new java.io.FileOutputStream(avatarFile);
                byte[] buffer = new byte[1024];
                int read;
                while ((read = in.read(buffer)) != -1) {
                  out.write(buffer, 0, read);
                }
                out.flush();
                out.close();
                in.close();
                
                // 加载新头像
                PImage newAvatar = parent.loadImage(avatarFile.getAbsolutePath());
                if (newAvatar != null) {
                  avatarImage = createCircularAvatar(newAvatar);
                  showToast("\u5934\u50cf\u8bbe\u7f6e\u6210\u529f"); // "头像设置成功"
                }
              }
            } catch (Exception e) {
              showToast("\u52a0\u8f7d\u5934\u50cf\u5931\u8d25"); // "加载头像失败"
            }
          }
        }
      });
    } catch (Exception e) {
      showToast("\u65e0\u6cd5\u6253\u5f00\u56fe\u7247\u9009\u62e9\u5668"); // "无法打开图片选择器"
    }
  }
  
  // 加载保存的头像数据
  private void loadAvatarFromSaved() {
    // 只设置头像大小，不再设置位置
    avatarSize = parent.width / 4;
    
    // 直接从固定位置加载头像
    java.io.File avatarFile = new java.io.File(activity.getExternalFilesDir(null), "avatar.jpg");
    if (avatarFile.exists()) {
      PImage newAvatar = parent.loadImage(avatarFile.getAbsolutePath());
      if (newAvatar != null) {
        avatarImage = createCircularAvatar(newAvatar);
      } else {
        loadDefaultAvatar();
      }
    } else {
      loadDefaultAvatar();
    }
  }
  
  // 创建圆形头像
  private PImage createCircularAvatar(PImage source) {
    // 使用当前设定的尺寸
    PImage result = parent.createImage((int)avatarSize, (int)avatarSize, PConstants.ARGB);
    result.loadPixels();
    
    // 将源图片缩放到当前设定的头像大小
    source.resize((int)avatarSize, (int)avatarSize);
    source.loadPixels();
    
    // 创建圆形裁剪
    float center = avatarSize / 2;
    float radius = avatarSize / 2;
    
    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        float distance = dist(x, y, center, center);
        if (distance < radius) {
          result.pixels[y * result.width + x] = source.pixels[y * source.width + x];
        } else {
          result.pixels[y * result.width + x] = parent.color(0, 0);  // 透明
        }
      }
    }
    result.updatePixels();
    return result;
  }
  
  // 加载默认头像
  private void loadDefaultAvatar() {
    try {
      // 直接从data文件夹加载默认头像图片
      PImage defaultAvatar = parent.loadImage("defaultAvatar.png");
      
      if (defaultAvatar != null) {
        // 将默认头像调整为当前头像大小
        defaultAvatar.resize((int)avatarSize, (int)avatarSize);
        
        // 将默认头像制作成圆形
        avatarImage = createCircularAvatar(defaultAvatar);
        
        // 将默认头像保存到文件系统
        try {
          java.io.File storageDir = activity.getExternalFilesDir(null);
          java.io.File avatarFile = new java.io.File(storageDir, "avatar.jpg");
          
          // 创建一个PGraphics对象来绘制avatarImage
          PGraphics pg = parent.createGraphics((int)avatarSize, (int)avatarSize);
          pg.beginDraw();
          pg.background(0, 0); // 透明背景
          pg.image(avatarImage, 0, 0);
          pg.endDraw();
          
          // 保存为文件
          pg.save(avatarFile.getAbsolutePath());
          
        } catch (Exception e) {
          e.printStackTrace();
          // 即使保存失败，也不影响当前会话中显示默认头像
        }
      } else {
        // 如果无法加载defaultAvatar.png，创建一个简单的蓝色圆形作为备用
        createFallbackAvatar();
      }
    } catch (Exception e) {
      e.printStackTrace();
      // 出现异常时，创建备用头像
      createFallbackAvatar();
    }
  }
  
  // 创建备用头像（在无法加载defaultAvatar.png时使用）
  private void createFallbackAvatar() {
    // 创建简单的蓝色圆形头像
    PImage fallbackAvatar = parent.createImage((int)avatarSize, (int)avatarSize, PConstants.ARGB);
    fallbackAvatar.loadPixels();
    
    // 中心点和半径
    int centerX = (int)avatarSize / 2;
    int centerY = (int)avatarSize / 2;
    int radius = (int)avatarSize / 2;
    
    // 填充蓝色圆形
    for (int y = 0; y < fallbackAvatar.height; y++) {
      for (int x = 0; x < fallbackAvatar.width; x++) {
        float distance = dist(x, y, centerX, centerY);
        if (distance < radius) {
          fallbackAvatar.pixels[y * fallbackAvatar.width + x] = parent.color(100, 160, 220); // 蓝色
        } else {
          fallbackAvatar.pixels[y * fallbackAvatar.width + x] = parent.color(0, 0); // 透明
        }
      }
    }
    
    fallbackAvatar.updatePixels();
    avatarImage = fallbackAvatar;
    
    // 显示错误提示
    showToast("\u65e0\u6cd5\u52a0\u8f7d\u9ed8\u8ba4\u5934\u50cf\uff0c\u4f7f\u7528\u5907\u7528\u5934\u50cf"); // "无法加载默认头像，使用备用头像"
  }
  
  // 检查是否点击了头像
  boolean isAvatarClicked(float x, float y) {
    return dist(x, y, avatarX, avatarY) < avatarSize/2;
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