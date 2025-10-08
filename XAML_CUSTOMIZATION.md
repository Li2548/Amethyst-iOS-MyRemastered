# Amethyst XAML 自定义布局系统

Amethyst Launcher 完全兼容 ShardLauncher 的 XAML 布局系统，允许用户通过自定义 XAML 文件来个性化主页界面。

## 功能特性

### 1. 完全兼容 ShardLauncher 布局
- 支持所有 ShardLauncher 的 XAML 元素
- 完全兼容 ShardLauncher 的属性和事件系统
- 可直接使用 ShardLauncher 的 XAML 文件

### 2. 支持的 XAML 元素

#### Card (卡片)
```xml
<local:MyCard Title="卡片标题" Margin="0,0,0,15" CanSwap="True" IsSwapped="False">
    <!-- 卡片内容 -->
</local:MyCard>
```
- `Title`: 卡片标题
- `Margin`: 外边距
- `CanSwap`: 是否可折叠
- `IsSwapped`: 是否默认折叠

#### StackPanel (堆栈面板)
```xml
<StackPanel Margin="25,40,23,15">
    <!-- 面板内容 -->
</StackPanel>
```
- `Margin`: 外边距

#### TextBlock (文本块)
```xml
<TextBlock Margin="0,0,0,4" FontSize="13" HorizontalAlignment="Center" Foreground="#8C7721"
           Text="文本内容" />
```
- `Margin`: 外边距
- `FontSize`: 字体大小
- `HorizontalAlignment`: 水平对齐方式 (Left, Center, Right)
- `Foreground`: 文本颜色
- `Text`: 文本内容

#### Hint (提示条)
```xml
<local:MyHint Text="提示内容" Theme="Blue" Margin="0,8,0,2" />
```
- `Text`: 提示文本
- `Theme`: 主题颜色 (Blue, Yellow, Red)
- `Margin`: 外边距

#### Button (按钮)
```xml
<local:MyButton Width="140" Height="35" HorizontalAlignment="Left" Padding="13,0,13,0"
                Text="按钮文本" EventType="打开网页" EventData="https://example.com/" />
```
- `Width`: 宽度
- `Height`: 高度
- `HorizontalAlignment`: 水平对齐方式
- `Padding`: 内边距
- `Text`: 按钮文本
- `EventType`: 事件类型
- `EventData`: 事件数据

#### TextButton (文本按钮)
```xml
<local:MyTextButton Margin="0,8,0,0" HorizontalAlignment="Center"
                    Text="文本按钮" EventType="打开网页" EventData="https://example.com/" />
```
- `Margin`: 外边距
- `HorizontalAlignment`: 水平对齐方式
- `Text`: 按钮文本
- `EventType`: 事件类型
- `EventData`: 事件数据

#### Image (图片)
```xml
<local:MyImage Height="50" HorizontalAlignment="Center" Source="https://example.com/image.png" />
```
- `Height`: 高度
- `HorizontalAlignment`: 水平对齐方式
- `Source`: 图片源地址

### 3. 支持的事件类型

#### 打开网页
```xml
<local:MyButton Text="打开网页" EventType="打开网页" EventData="https://example.com/" />
```

#### 弹出窗口
```xml
<local:MyButton Text="显示弹窗" EventType="弹出窗口" EventData="标题|内容文本" />
```

#### 启动游戏
```xml
<local:MyButton Text="启动游戏" EventType="启动游戏" EventData="1.12.2" />
<local:MyButton Text="启动并连接服务器" EventType="启动游戏" EventData="1.20.1|mc.hypixel.net" />
```

## 使用方法

### 1. 导入 XAML 文件
1. 在设置中找到"导入XAML布局"选项
2. 选择您的 XAML 文件
3. 重启应用以应用新布局

### 2. XAML 文件位置
- 应用会优先加载 Documents 目录下的 `custom_home.xaml` 文件
- 如果不存在，则加载应用包内的 `home.xaml` 文件

### 3. 示例 XAML 文件
```xml
<local:MyCard Title="欢迎使用 Amethyst" Margin="0,0,0,15">
    <StackPanel Margin="25,40,23,15">
        <TextBlock Margin="0,0,0,4" FontSize="13" HorizontalAlignment="Center" Foreground="{DynamicResource ColorBrush1}"
                   Text="本启动器完全兼容 ShardLauncher 布局！" />
    </StackPanel>
</local:MyCard>
```

## 注意事项

1. 确保 XAML 文件格式正确
2. 图片资源需要使用有效的 URL 地址
3. 某些 ShardLauncher 特定功能可能需要额外实现
4. 建议在导入前备份当前布局文件

## 技术实现

### XAML 解析器
- 使用 libxml2 解析 XAML 文件
- 支持所有标准 XAML 元素和属性
- 可扩展以支持更多自定义元素

### 渲染引擎
- 使用 UIKit 实现界面渲染
- 支持 Auto Layout 自适应布局
- 完全兼容 iOS 14.0+ 系统

### 事件处理
- 支持按钮点击事件
- 支持网页打开、弹窗显示、游戏启动等功能
- 可扩展以支持更多事件类型