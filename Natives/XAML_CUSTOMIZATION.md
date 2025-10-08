# Amethyst Launcher XAML 自定义布局系统

## 概述

本系统实现了类似 ShardLauncher 的 XAML 自定义布局功能，允许用户通过编辑 XAML 文件来自定义启动器主页的布局和内容。

## 支持的 XAML 元素

### 1. Card (卡片)
可折叠的内容容器

**属性:**
- `Title`: 卡片标题
- `Margin`: 边距 (格式: "left,top,right,bottom")
- `CanSwap`: 是否可折叠 (True/False)
- `IsSwapped`: 是否默认折叠 (True/False)

**示例:**
```xml
<local:MyCard Title="示例卡片" Margin="0,0,0,15" CanSwap="True" IsSwapped="False">
    <StackPanel Margin="25,40,23,15">
        <!-- 内容 -->
    </StackPanel>
</local:MyCard>
```

### 2. TextBlock (文本块)
显示文本内容

**属性:**
- `Text`: 文本内容
- `FontSize`: 字体大小
- `FontWeight`: 字体粗细 (Bold/Normal)
- `Foreground`: 文本颜色 (十六进制颜色值或动态资源)
- `Margin`: 边距
- `HorizontalAlignment`: 水平对齐方式 (Left/Center/Right)

**示例:**
```xml
<TextBlock Margin="0,0,0,4" FontSize="13" HorizontalAlignment="Center" Foreground="#8C7721"
           Text="这是一段示例文本。" />
```

### 3. Button (按钮)
可点击的按钮元素

**属性:**
- `Text`: 按钮文本
- `Margin`: 边距
- `Width`: 宽度
- `Height`: 高度
- `ColorType`: 颜色类型 (Highlight/Red)

**示例:**
```xml
<local:MyButton Margin="0,4,0,10" Height="35" HorizontalAlignment="Left" Padding="25,0,25,0"
                Text="点击我" ColorType="Highlight" />
```

### 4. Hint (提示条)
彩色提示信息条

**属性:**
- `Text`: 提示文本
- `Margin`: 边距
- `Theme`: 主题颜色 (Blue/Yellow/Red)

**示例:**
```xml
<local:MyHint Text="这是一个提示条。" Theme="Blue" />
```

### 5. StackPanel (堆栈面板)
用于组织其他元素

**属性:**
- `Margin`: 边距
- `Orientation`: 方向 (Horizontal/Vertical)
- `HorizontalAlignment`: 水平对齐方式

**示例:**
```xml
<StackPanel Margin="25,40,23,15" Orientation="Vertical">
    <!-- 子元素 -->
</StackPanel>
```

## 动态资源颜色

支持以下动态资源颜色引用：
- `{DynamicResource ColorBrush1}`: 主题色
- `{DynamicResource ColorBrush2}`: 次要色
- `{DynamicResource ColorBrush3}`: 第三色

## 文件位置

XAML 布局文件位于应用的文档目录中，文件名为 `home.xaml`。用户可以编辑此文件来自定义主页布局。

## 默认内容

如果未找到自定义的 XAML 文件，系统将使用默认的布局内容。

## 扩展性

该系统设计为可扩展的，可以轻松添加新的 XAML 元素类型和属性支持。