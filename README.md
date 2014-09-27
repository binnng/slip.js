slip.js
=======

移动端跟随手指滑动组件，零依赖。

### 示例

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

### 源码
源码用`CoffeeScript`书写，`slip.js`为其生成代码。
