slip.js
========

移动端跟随手指滑动组件，零依赖。

### 文档
[文档](http://binnng.github.io/slip.js/docs)

### 源码
源码用CoffeeScript书写，[查看源码](http://binnng.github.io/slip.js/docs/slip.html)。

### 下载
[min.slip.js](http://binnng.github.io/slip.js/dist/min.slip.js)


### 示例
手机访问：

[搜狐视频客户端完美适配iOS8](http://binnng.github.io/slip.js/demo/sohutv-ios8.html)

![搜狐视频客户端完美适配iOS8](http://qianbao.baidu.com/huodong/15/qrcode?text=http://binnng.github.io/slip.js/demo/sohutv-ios8.html&size=4)

[匆匆那年](http://binnng.github.io/slip.js/demo/sohutv-ccnn.html)

![匆匆那年](http://qianbao.baidu.com/huodong/15/qrcode?text=http://binnng.github.io/slip.js/demo/sohutv-ccnn.html&size=4)

### 安装

使用 [bower](http://bower.io/) 安装

```
$ bower install binnng/slip.js --save
```

更新版本

```
$ bower update
```


使用 [Yeoman](http://yeoman.io/) 安装

```
$ npm install -g generator-webapp-slip
$ yo webapp-slip
```

### 快速上手

一个全屏可滑动的宣传网页：

```javascript
var ele = document.getElementById("slip");

// 垂直滑动
Slip(ele, "y").webapp();

// 水平滑动
// Slip(ele, "x").webapp();
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

  mySlip
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
      console.log(this.coord);

      // 滑动方向
      console.log(this.orient);
    });
```
