# ```
# Slip.js 0.2.0
# 
# ! CopyRight: binnng http://github.com/binnng/slip.js
# Licensed under: MIT
# http://binnng.github.io/slip.js
# ```

# Fork me on [Github!](https://github.com/binnng/slip.js)

((WIN, DOC) ->

  # 定义
  # ======

  # 缓存，便于变量名压缩
  UNDEFINED = undefined
  NULL = null

  X = "x"
  Y = "y"
  XY = "xy"

  LEFT = "left"
  RIGHT = "right"
  UP = "up"
  DOWN = "down"

  # 滑动方向中最小允许距离
  # 小于这个值不触发滑动
  MIN_ALLOW_DISTANCE = 10

  # 如果是单方向滑动
  # 非滑动方向最大允许距离
  MAX_OPP_ALLOW_DISTANCE = 40

  # CSS的前缀
  CSS_PREFIX_MAP = [
    "webkit"
    "moz"
    "ms"
    "o"
    ""
  ]

  # 从一串包含数字的字符串中提取数字
  # 用于在css值中提取偏移值
  # ```
  # transform: translate(-270px, 180px, 0);
  # ```
  NUMBER_REG = /\-?[0-9]+\.?[0-9]*/g

  # 是不是触屏设备
  # 如果是触屏设备使用`touch`事件，否则使用`mouse`事件
  IsTouch = 'ontouchend' of WIN

  # 定义开始，进行，结束的事件名
  START_EVENT = if IsTouch then 'touchstart' else 'mousedown'
  MOVE_EVENT = if IsTouch then 'touchmove' else 'mousemove'
  END_EVENT = if IsTouch then 'touchend' else 'mouseup'

  # WINDOW_HEIGHT WINDOW_WIDTH
  # -----
  # 浏览器窗口的高度，宽度
  WINDOW_HEIGHT = WIN['innerHeight']
  WINDOW_WIDTH = WIN['innerWidth']

  # noop
  # -----
  # 空函数
  # 作为默认的回调函数
  noop = ->

  # 方法
  # ====

  # setTransition
  # -----
  # 设置css的transition
  # * `ele`: 原生的dom元素
  # * `css`: transition的值
  setTransition = (ele, css) ->
    for prefix in CSS_PREFIX_MAP
      name = if prefix then "#{prefix}Transition" else "transition"
      ele.style[name] = css

  # setTranslate
  # -----
  # 设置元素的CSS位移
  # * `ele`: 原生的DOM元素
  # * `x|y|z`: 偏移的x, y, z
  setTranslate = (ele, x, y, z) ->
    for prefix in CSS_PREFIX_MAP
      name = if prefix then "#{prefix}Transform" else "transform"
      ele.style[name] = "translate3d(#{x or 0}px, #{y or 0}px, #{z or 0}px)"

  # getTranslate
  # -----
  # 获取元素的translate值
  # * `ele`: 原生的dom元素
  getTranslate = (ele) ->

    translate = []
    css = ''
    coord = ''

    for prefix in CSS_PREFIX_MAP
      name = if prefix then "#{prefix}Transform" else "transform"

      css = ele.style[name]

      if css and typeof css is 'string'
        coord = css.match(/\((.*)\)/g)[0]
        translate = coord and coord.match NUMBER_REG
        break

    if translate.length
      x: translate[0] or 0
      y: translate[1] or 0
      z: translate[2] or 0

  # Slip类
  # =====

  # class Slip
  # -----
  # 核心的`Slip`构造函数
  class Slip

    # 获取事件触发距离
    # 处理一堆兼容
    getCoordinatesArray = [

      # 移动端设备
      (event) ->
        touches = event.touches and ((if event.touches.length then event.touches else [event]))
        e = (event.changedTouches and event.changedTouches[0]) or (event.originalEvent and event.originalEvent.changedTouches and event.originalEvent.changedTouches[0]) or touches[0].originalEvent or touches[0]
        "x": e.clientX
        "y": e.clientY

      # pc设备
      (event) ->
        e = event
        "x": e.clientX
        "y": e.clientY
    ]

    getCoordinates = if IsTouch then getCoordinatesArray[0] else getCoordinatesArray[1]

    # 构造器
    # * `ele`: 原生的dom元素，定义可以被滑动的元素
    # * `direction`: 可被滑动的方向，有三个合法值`'x'`, `'y'`, `'xy'`，默认为 `'x'`
    constructor: (@ele, @direction) ->

      # 是不是被按下了，只有按下才允许移动
      @_isPressed = no

      # * 开始的回调
      # * 移动中回调
      # * 结束的回调
      @onStart = @onMove = @onEnd = noop
      
      # * `coord`: 元素实际坐标值
      # * `eventCoords`: 手指的坐标，用于在各种事件中传递
      # * `cacheCoords`: 当touchstart时候，缓存的当前位移，用于touchmove中计算
      # * `finger`: 手指的位移
      # * `absFinger`: 手指位移的绝对值
      @coord = @eventCoords = @cacheCoords = @finger = @absFinger = NULL

      # 结束后手指滑动的方向
      # 
      # 这个值是个数组
      # * 左滑: `['left']`
      # * 右滑: `['right']`
      # * 上滑: `['up']`
      # * 下滑: `['down']`
      # * 左上滑: `['left', 'up']`
      # * 右上滑: `['right', 'up']`
      # * 右下滑: `['right', 'down']`
      # * 左下滑: `['left', 'down']`
      @orient = []

      # slider
      @isSlider = no

      # webapp当前页
      # 只有设置webapp才有值
      @isWebapp = no

      # 默认的滑屏过渡时间，单位为ms
      # 这个值可以通过`time`方法来重置
      # ```
      # // 设置过度时间为200ms
      # Slip(ele, 'y').time(200);
      # ```
      @duration = "400"

    start : (fn) -> (@onStart = fn) and @
    move  : (fn) -> (@onMove  = fn) and @
    end   : (fn) -> (@onEnd   = fn) and @

    # Slip(ele).setCoord(...)
    # -----
    # 设置元素坐标
    # 如果元素初始化就有一定的偏移，就可以使用这个方法
    # * `userCoords`: 一个坐标对象
    # ```
    # Slip(ele, 'x')
    #   .setCoord({
    #     x: 100,
    #     y: 0,
    #     z: 0
    #   });
    # ```
    setCoord: (userCoords) ->
      coords = @coord = 
        "x": userCoords[X] or 0
        "y": userCoords[Y] or 0

      ele = @ele

      setTranslate ele, coords[X], coords[Y]
      ele.setAttribute attr, coords[attr] for attr of coords

      @

    # 触摸开始的回调
    onTouchStart: (event) ->
      @_isPressed = yes

      @eventCoords = getCoordinates event

      @cacheCoords = @coord

      # 清空手指位移
      @finger = @absFinger = NULL

      @onSliderStart event if @isSlider
      ret = @onStart.apply @, [event]

    # 触摸进行中的回调
    onTouchMove: (event) ->
      event.preventDefault()

      return no unless @_isPressed

      moveCoords = getCoordinates event

      direction = @direction

      # 手指偏移
      # * 左滑 finger.x < 0
      # * 右滑 finger.x > 0
      # * 上滑 finger.y < 0
      # * 下滑 finger.y > 0
      finger = @finger = 
        x: moveCoords.x - @eventCoords.x
        y: moveCoords.y - @eventCoords.y

      # 手指偏移的绝对值
      absFinger = @absFinger = 
        x: Math.abs finger.x
        y: Math.abs finger.y

      # 单方向滑动时，小于正方向最小距离，大于反方向最大距离，不是正确的手指行为
      if direction isnt XY
        # 反方向
        oppDirection = if direction is X then Y else X

        if absFinger[direction] < MIN_ALLOW_DISTANCE or absFinger[oppDirection] > MAX_OPP_ALLOW_DISTANCE
          return no

      # 手指移动方向
      orient = []
      if absFinger.x > MIN_ALLOW_DISTANCE
        orient.push if finger.x < 0 then LEFT else RIGHT

      if absFinger.y > MIN_ALLOW_DISTANCE
        orient.push if finger.y < 0 then UP else DOWN

      @orient = orient

      # 执行用户定义的进行中回调
      # 用户定义回调可以有返回值
      # 如果返回值为`false`，那就不继续了
      ret = @onMove.apply @, [event]

      return no if ret is no

      ele = @ele

      # 元素的实际位移
      eleMove = @coord = 
        "x": if direction.indexOf(X) < 0 then @cacheCoords[X] else @cacheCoords[X] - 0 + finger.x
        "y": if direction.indexOf(Y) < 0 then @cacheCoords[Y] else @cacheCoords[Y] - 0 + finger.y

      setTranslate ele, eleMove[X], eleMove[Y]

      # 在元素上标记位移
      ele.setAttribute attr, eleMove[attr] for attr of eleMove

    # 触摸结束的回调
    onTouchEnd: (event) ->
      @_isPressed = no

      ele = @ele

      @onSliderEnd event if @isSlider

      # 结束后设置一次translate
      # 防止用户在自己定义的回调中改变了translate的值
      trans = getTranslate this.ele
      @setCoord trans if trans

      # 最后来清空手指滑动的方向
      @orient = []

    onSliderStart: (event) ->
      setTransition @ele, NULL

    # 当滑动结束时，针对轮播器做些特别处理
    onSliderEnd: (event, data = {}) ->

      {
        jumpPage
      } = data

      isJump = jumpPage

      # 手指滑动的方向
      orient = @orient.join ""

      trans = 0

      # 是不是超出了，即第一页向前滑，最后一页向后滑
      isOut = no

      page = @page
      pageNum = @pageNum
      ele = @ele
      duration = @duration
      absFinger = @absFinger

      isUp = orient.indexOf(UP) > -1
      isDown = orient.indexOf(DOWN) > -1
      isLeft = orient.indexOf(LEFT) > -1
      isRight = orient.indexOf(RIGHT) > -1

      # 是不是垂直滑动
      isVerticalWebapp = @direction is Y

      if jumpPage isnt UNDEFINED
        page = jumpPage

      else
        if isVerticalWebapp
          page++ if isUp
          page-- if isDown
        else 
          page++ if isLeft
          page-- if isRight

      # 归位超出的页数
      if page >= pageNum
        page = pageNum - 1
        isOut = yes

      if page < 0
        page = 0
        isOut = yes


      # 这里做了个细节处理
      # 1. 当用户定义整页滑动的时长为400ms
      # 2. 如果在超出时，反弹回去的时间不应为400ms
      # 3. 反弹的距离 < 页面的距离
      # 4. 所以反弹的时长 = 整页的时长 * (反弹的距离 / 整页的距离)
      # 5. 即反弹的时长 < 整页过渡的时长
      if isOut is yes and not isJump
        duration *= if isVerticalWebapp then absFinger[Y] / @pageHeight else absFinger[X] / @pageWidth
        
      setTransition ele, "all #{duration}ms ease-in"

      if isVerticalWebapp
        trans = "-#{page * @pageHeight}"
        setTranslate ele, 0, trans, 0
      else
        trans = "-#{page * @pageWidth}"
        setTranslate ele, trans, 0, 0

      @page = page

      @onTouchEnd.call @, NULL if isJump

      ret = @onEnd.apply @, [event]

      @

    # 初始化
    init: -> 
      @coord = "x": 0, "y": 0

      # 之所以加上下划线方法，是为了给 `destroy` 用
      onTouchStart = @_onTouchStart = (event) => @onTouchStart event
      onTouchMove = @_onTouchMove = (event) => @onTouchMove event
      onTouchEnd = @_onTouchEnd= (event) => @onTouchEnd event

      ele = @ele
      ele.addEventListener START_EVENT, onTouchStart, no
      ele.addEventListener MOVE_EVENT, onTouchMove, no
      ele.addEventListener END_EVENT, onTouchEnd, no

      # 初始化元素位移
      initMove = @coord = "x": 0, "y": 0

      direction = @direction
      setTranslate ele, initMove[X], initMove[Y]

      ele.setAttribute attr, initMove[attr] for attr of initMove

      @

    # Slip(ele).destroy()
    # -----
    # 摧毁元素的滑动
    destroy: ->

      ele = @ele
      ele.removeEventListener START_EVENT, @_onTouchStart, no
      ele.removeEventListener MOVE_EVENT, @_onTouchMove, no
      ele.removeEventListener END_EVENT, @_onTouchEnd, no

      @

    # Slip(ele).slider()
    # -----
    # 设置是个普通的轮播器
    # `elPages`: 可接受三种类型的值
    # 1. *String*: 传入一个选择器
    # 2. *Array|类Array的Obejct*: 子元素列表
    # 3. *undifined|null...* 传入空值，那就默认获取滑动元素的所有直接子元素（儿子）。
    # 
    # 推荐第二种做法。
    slider: (elPages)->
      ele = @ele

      # 如果传入了选择器
      if typeof elPages is "string"
        elPages = ele.querySelectorAll(elPages)
      
      # 传入为空
      else if not elPages
        elPages = []
        elChilds = ele.childNodes

        for elChild in elChilds
          elPages.push elChild if elChild.nodeType is 1

      @isSlider = yes
      @page = 0
      @elPages = elPages

      elPagesLen = elPages.length
      pageNum = @pageNum = if elPagesLen then elPagesLen else 0

      # 横向滑动
      if @direction is X
        elPage.style.cssFloat = LEFT for elPage in elPages

      @

    # Slip(ele).webapp()
    # -----
    # 设置页面是个全屏的webapp
    # 继承了slider，再做些特别处理。
    webapp: (elPages) ->
      @isWebapp = yes

      # 如果是webapp肯定全屏
      @.slider(elPages).fullscreen()

      elPages = @elPages
      ele = @ele
      pageNum = @pageNum

      ele.style.height = "#{WINDOW_HEIGHT * pageNum}px"
      @height WINDOW_HEIGHT

      # 横向滑动的webapp
      @width WINDOW_WIDTH if @direction is X
      
      @

    # Slip(ele).slider().height(200)
    # -----
    # 设置轮播器的高度
    height: (num)->
      ele = @ele
      elPages = @elPages
      pageNum = @pageNum
      num = String(num).replace "px", ""

      if num is "100%"
        num = WINDOW_HEIGHT

      @pageHeight = num

      if @direction is X
        ele.style.height = "#{num}px"

      elPage.style.height = "#{num}px" for elPage in elPages

      @

    # Slip(ele).slider().width('100%');
    # -----
    # 设置轮播器的宽度
    width: (num)->
      ele = @ele
      elPages = @elPages
      pageNum = @pageNum
      num = String(num).replace "px", ""

      if num is "100%"
        num = WINDOW_WIDTH

      @pageWidth = num

      if @direction is X
        ele.style.width = "#{num * pageNum}px"

      elPage.style.width = "#{num}px" for elPage in elPages

      @

    # Slip(ele).fullscreen()
    # -----
    # 设置全屏
    fullscreen: ->

      ele = @ele
      child = ele

      while parent = child.parentNode

        if parent.nodeType is 1
          parent.style.height = "100%"
          parent.style.overflow = "hidden"

        child = parent

      @

    # Slip(ele).webapp().time(200)
    # -----
    # 设置轮播时页面切换的过渡时长
    time: (duration) ->
      @duration = String(duration).replace "ms", ""

      @

    # jump(page)
    # ------
    # 跳转到指定页
    jump: (page) ->
      @onSliderEnd NULL, jumpPage: page

      @

  # slip
  # 暴露到window的对象，内部实例化`Slip`
  entry = (ele, direction) ->
    instance = new Slip ele, direction or X
    instance.init()

  if typeof define is "function"
    define "binnng/slip.js", (require, exports, module) ->
      entry

  else
    WIN["Slip"] = entry

) window, document