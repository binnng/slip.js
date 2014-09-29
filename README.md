slip.js
=======

移动端跟随手指滑动组件，零依赖。

### 示例

手机访问：

[搜狐视频客户端完美适配iOS8](http://binnng.github.io/slip.js/demo/sohutv-ios8.html)

[匆匆那年](http://binnng.github.io/slip.js/demo/sohutv-ccnn.html)

或扫描二维码访问：

搜狐视频客户端完美适配iOS8

![搜狐视频客户端完美适配iOS8](http://qianbao.baidu.com/huodong/15/qrcode?text=http://binnng.github.io/slip.js/demo/sohutv-ios8.html&size=6)

匆匆那年

![匆匆那年](http://qianbao.baidu.com/huodong/15/qrcode?text=http://binnng.github.io/slip.js/demo/sohutv-ccnn.html&size=6)

### 简单代码

一个全屏可滑动的宣传网页：

```javascript
var ele = document.getElementById("slip");

// 垂直滑动
Slip(ele, "y").webaapp();

// 水平滑动
// Slip(ele, "x").webaapp();
```
一个可滑动的高度为200px的轮播器：
```javascript
var ele = document.getElementById("slip");

Slip(ele, "x").slider()
  .height(200);

```

一个可滑动的元素，开始滑动，滑动中，结束滑动都有自己的定制：
```javascript
  var ele = document.getElementById("slip");
  var mySlip = Slip(ele, "xy");

  mySlip.setCoord({
    x: 0,
    y: 120
  })
    .start(function(event) {
      console.log('start');

      // 事件对象
      console.log(event);
      // 当前坐标值
      console.log(this.coord);
    })
    .move(function(event) {
      console.log('move');
    })
    .end(function() {
      console.log('end');
      cosole.log(this.coord);
      
      // 滑动方向
      console.log(this.orient);
    });
```

## 文档

### 使用

window下暴露了名为 `Slip` 的全局函数。

#### `Slip`

###### 参数：
* `el`: 原生的dom元素
* `direction`: *String*, 元素可滑动的方向，`"x"`, `"y"`, `"xy"`

```javascript
var slip = Slip(el, "x");
```

#### 方法

##### `setCoord`
设置元素坐标位置

###### 参数
* `coord`: *Object*, 元素坐标位置

```javascript
slip.setCoord({
  x: 10,
  y: 0
});
```
##### `destroy`
销毁元素的滑动

###### 参数
无

```javascript
slip.destroy();
```

#### 事件

##### `start`

###### 参数
* `fn`: *Funciton* 触碰开始的回调

##### `move`

###### 参数
* `fn`: *Function* 触碰进行中的回调

##### `end`

###### 参数
* `fn`: *Function* 触碰结束的回调

#### 属性

##### `coord`
*Object* 元素的坐标值

* `coord.x`: x坐标值
* `coord.y`: y坐标值

##### `finger`
*Object* 手指的偏移

* `finger.x`: x偏移值
* `finger.y`: y偏移值


##### `orient`
*Array* 手指滑动的方向，这个值会在手指滑动过程中变化

**注意：`orient`的值是数组**

* 左滑: `['left']`
* 右滑: `['right']`
* 上滑: `['up']`
* 下滑: `['down']`
* 左上滑: `['left', 'up']`
* 右上滑: `['right', 'up']`
* 右下滑: `['right', 'down']`
* 左下滑: `['left', 'down']`

### 轮播器

#### 方法

##### `slider`
设置轮播器

```javascript
Slip(ele, "x").slider();
```

###### 参数
* `elPages`: *String|NodeList|空*，可滑动容器（指的是传个Slip方法的dom元素）内的子元素，可以传一个CSS选择器（String），也可以传子元素列表（nodeList），也可以传空，传空情况下会取所有容器内的子元素。

#### `height`
设置轮播器的高度

```javascript
Slip(ele, "x").slider().height(200);
```

##### 参数
* `num`: *Number|String*, 高度值，数字或者带有px的值。
* 
#### `width`
设置轮播器的宽度

##### 参数
* `num`: *Number|String*, 宽度值，数字或者带有px的值。

### Webapp 全屏网页
如[搜狐视频客户端完美适配iOS8](http://binnng.github.io/slip.js/demo/sohutv-ios8.html)这种形式的网页。

#### 方法

##### `webapp`
```javascript
Slip(ele, "y").webapp();
```

### 源码
源码用`CoffeeScript`书写，`slip.js`为其生成代码。
