slip.js
=======

移动端跟随手指滑动组件，零依赖。

## 文档

### 完整demo

```javascript
	var mySlip = Slip(ele, "xy");

	mySlip.setCoord({
		x: 0,
		y: 120
	})
		.start(function(event) {
			console.log('start');

			// 事件对象
			cossole.log(event);
			// 当前坐标值
			cossole.log(this.coord);
		})
		.move(function(event) {
			console.log('move');
		})
		.end(function() {
			console.log('end');
			cosole.log(this.coord);
		});
```

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

### 源码
源码用`CoffeeScript`书写，`slip.js`为其生成代码。
