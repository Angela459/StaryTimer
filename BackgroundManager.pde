class BackgroundManager {
  private PApplet parent;
  private Activity activity;
  private PImage backgroundImage;  // 背景图片
  private String backgroundPath;  // 背景图片文件路径
  private FileManager fileManager;  // 添加FileManager引用
  
  BackgroundManager(PApplet parent) {
    this.parent = parent;
    this.activity = parent.getActivity();
    this.fileManager = ((StaryTimerAndroid)parent).fileManager;
    loadBackgroundFromSaved();
  }
  
  // 加载保存的背景图片
  public void loadBackgroundFromSaved() {
    // 从固定位置加载背景图片
    java.io.File backgroundFile = new java.io.File(activity.getExternalFilesDir(null), "background.jpg");
    if (backgroundFile.exists()) {
      PImage newBackground = parent.loadImage(backgroundFile.getAbsolutePath());
      if (newBackground != null) {
        backgroundImage = newBackground;
        backgroundImage.resize(parent.width, parent.height);
      } else {
        loadDefaultBackground();
      }
    } else {
      loadDefaultBackground();
    }
  }
  
  // 加载默认背景
  private void loadDefaultBackground() {
    try {
      // 修改加载路径，直接使用"background.png"而不是"data/background.png"
      backgroundImage = parent.loadImage("background.png");
      
      if (backgroundImage == null) {
        // 尝试加载默认背景图片
        backgroundImage = parent.loadImage("defaultBackground.png");
        
        if (backgroundImage == null) {
          // 如果默认背景不存在，创建一个纯黑色背景
          createFallbackBackground();
        } else {
          // 显示成功加载默认背景的提示
          showToast("\u6210\u529f\u52a0\u8f7d\u9ed8\u8ba4\u80cc\u666f"); // "成功加载默认背景"
        }
      } else {
        // 显示成功加载背景的提示
        showToast("\u6210\u529f\u52a0\u8f7d\u80cc\u666f"); // "成功加载背景"
      }
      
      if (backgroundImage != null) {
        // 调整大小以适应屏幕
        backgroundImage.resize(parent.width, parent.height);
      }
    } catch (Exception e) {
      e.printStackTrace();
      // 创建备用背景
      createFallbackBackground();
    }
  }
  
  // 创建备用背景（当无法加载background.png时使用）
  private void createFallbackBackground() {
    backgroundImage = parent.createImage(parent.width, parent.height, PConstants.RGB);
    backgroundImage.loadPixels();
    for (int i = 0; i < backgroundImage.pixels.length; i++) {
      backgroundImage.pixels[i] = parent.color(0); // 黑色
    }
    backgroundImage.updatePixels();
    
    // 显示错误提示
    showToast("\u65e0\u6cd5\u52a0\u8f7d\u9ed8\u8ba4\u80cc\u666f\uff0c\u4f7f\u7528\u7eaf\u9ed1\u80cc\u666f"); // "无法加载默认背景，使用纯黑背景"
  }
  
  // 绘制背景
  public void drawBackground() {
    if (backgroundImage != null) {
      parent.pushStyle();
      parent.imageMode(CORNER); // 明确设置为CORNER模式
      parent.image(backgroundImage, 0, 0, parent.width, parent.height);
      parent.popStyle();
    }
  }
  
  // 处理背景图片选择
  public void changeBackground() {
    activity.runOnUiThread(new Runnable() {
      public void run() {
        // 创建选择对话框
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(activity);
        builder.setTitle("\u80cc\u666f\u56fe\u7247\u8bbe\u7f6e"); // "背景图片设置"
        
        // 设置选项
        final String[] options = {"\u9ed8\u8ba4\u80cc\u666f", "\u81ea\u5b9a\u4e49\u80cc\u666f"}; // "默认背景", "自定义背景"
        builder.setItems(options, new android.content.DialogInterface.OnClickListener() {
          public void onClick(android.content.DialogInterface dialog, int which) {
            if (which == 0) {
              // 选择默认背景
              loadDefaultBackground();
              // 保存默认背景
              saveDefaultBackground();
              showToast("\u5df2\u8bbe\u7f6e\u9ed8\u8ba4\u80cc\u666f"); // "已设置默认背景"
              // 重新初始化背景管理器
              ((StaryTimerAndroid)parent).reinitializeBackgroundManager();
            } else if (which == 1) {
              // 选择自定义背景，打开图片选择器
              openBackgroundImagePicker();
            }
          }
        });
        
        // 显示对话框
        builder.show();
      }
    });
  }
  
  // 打开背景图片选择器
  private void openBackgroundImagePicker() {
    android.content.Intent intent = new android.content.Intent(android.content.Intent.ACTION_PICK);
    intent.setType("image/*");
    
    try {
      activity.startActivityForResult(intent, 2); // 使用不同的请求码与头像区分
      
      ((StaryTimerAndroid)parent).registerActivityResult(new ActivityResultCallback() {
        public void handleResult(int requestCode, int resultCode, android.content.Intent data) {
          if (requestCode == 2 && resultCode == android.app.Activity.RESULT_OK && data != null) {
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
                java.io.File backgroundFile = new java.io.File(storageDir, "background.jpg");
                
                // 复制选中的图片到私有目录
                java.io.InputStream in = activity.getContentResolver().openInputStream(selectedImage);
                java.io.OutputStream out = new java.io.FileOutputStream(backgroundFile);
                byte[] buffer = new byte[1024];
                int read;
                while ((read = in.read(buffer)) != -1) {
                  out.write(buffer, 0, read);
                }
                out.flush();
                out.close();
                in.close();
                
                // 加载新背景
                PImage newBackground = parent.loadImage(backgroundFile.getAbsolutePath());
                if (newBackground != null) {
                  backgroundImage = newBackground;
                  backgroundImage.resize(parent.width, parent.height);
                  showToast("\u80cc\u666f\u66f4\u65b0\u6210\u529f"); // "背景更新成功"
                  
                  // 重新初始化背景管理器
                  ((StaryTimerAndroid)parent).reinitializeBackgroundManager();
                }
              }
            } catch (Exception e) {
              showToast("\u52a0\u8f7d\u80cc\u666f\u5931\u8d25"); // "加载背景失败"
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
  
  // 保存默认背景到文件
  private void saveDefaultBackground() {
    if (backgroundImage != null) {
      try {
        java.io.File storageDir = activity.getExternalFilesDir(null);
        java.io.File backgroundFile = new java.io.File(storageDir, "background.jpg");
        
        // 创建一个PGraphics对象来绘制背景图片
        PGraphics pg = parent.createGraphics(parent.width, parent.height);
        pg.beginDraw();
        pg.image(backgroundImage, 0, 0, parent.width, parent.height);
        pg.endDraw();
        
        // 保存为文件
        pg.save(backgroundFile.getAbsolutePath());
        
      } catch (Exception e) {
        e.printStackTrace();
        // 即使保存失败，也不影响当前会话中显示默认背景
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
  
  // 获取背景图片
  public PImage getBackgroundImage() {
    return backgroundImage;
  }
} 