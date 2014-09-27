((WIN, DOC) ->

  # 滑动方向中最小允许距离
  MIN_ALLOW_DISTANCE = 10

  # 非滑动方向最大允许距离
  MAX_OPP_ALLOW_DISTANCE = 40

  # CSS前缀
  CSS_PREFIX_MAP = [
    "webkit"
    "moz"
    "ms"
    "o"
  ]

  X = "x"
  Y = "y"
  XY = "xy"

  noop = ->

  ###
  # 设置元素的CSS位移
  # ele 原生的DOM元素
  ###
  setTranslate = (ele, x, y, z) ->
    cssPrefix = CSS_PREFIX_MAP.concat []
    cssPrefix.push ""

    for prefix in cssPrefix
      name = if prefix then "#{prefix}Transform" else "transform"
      ele.style[name] = "translate3d(#{x or 0}px, #{y or 0}px, #{z or 0}px)"


  # 核心的slip，接受一个原生的DOM元素
  class Slip

    # 获取事件触发距离
    # 处理一堆兼容
    getCoordinates = (event) ->
      touches = event.touches and ((if event.touches.length then event.touches else [event]))
      e = (event.changedTouches and event.changedTouches[0]) or (event.originalEvent and event.originalEvent.changedTouches and event.originalEvent.changedTouches[0]) or touches[0].originalEvent or touches[0]
      "x": e.clientX
      "y": e.clientY

    constructor: (@ele, @direction) ->


      # 开始的回调
      # 移动中回调
      # 结束的回调
      @onStart = @onMove = @onEnd = noop
      
      # coord: 元素实际坐标值
      # eventCoords: 事件的位移，用于在各种事件中传递
      # chcheCoords: 当touchstart时候，缓存的当前位移，用于touchmove中计算
      @coord = @eventCoords = @cacheCoords = null

    start : (fn) -> (@onStart = fn) and @
    move  : (fn) -> (@onMove  = fn) and @
    end   : (fn) -> (@onEnd   = fn) and @

    # 设置元素坐标
    setCoord: (userCoords) ->
      coords = @coord = 
        "x": userCoords[X] or 0
        "y": userCoords[Y] or 0

      ele = @ele

      setTranslate ele, coords[X], coords[Y]
      ele.setAttribute attr, coords[attr] for attr of coords

      @

    onTouchStart: (event) ->
      @eventCoords = getCoordinates event

      @cacheCoords = @coord

      @onStart.apply @, [event]

    onTouchMove: (event) ->
      event.preventDefault()

      moveCoords = getCoordinates event

      direction = @direction

      # 手指位移
      # 左滑 eventMove.x < 0 右滑 eventMove.x > 0
      # 上滑 eventMove.y < 0 下滑 eventMove.y > 0
      eventMove = 
        "x": moveCoords.x - @eventCoords.x
        "y": moveCoords.y - @eventCoords.y

      # 手指位移绝对值
      absEventMove = 
        "x": Math.abs eventMove[X]
        "y": Math.abs eventMove[Y]

      # 元素位移
      eleMove = @coord = 
        "x": if direction.indexOf(X) < 0 then @cacheCoords[X] else @cacheCoords[X] - 0 + eventMove[X]
        "y": if direction.indexOf(Y) < 0 then @cacheCoords[Y] else @cacheCoords[Y] - 0 + eventMove[Y]

      # 单方向滑动时，小于正方向最小距离，大于反方向最大距离，不是正确的手指行为
      if direction isnt XY
        # 反方向
        oppDirection = if direction is X then Y else X

        if absEventMove[direction] < MIN_ALLOW_DISTANCE or absEventMove[oppDirection] > MAX_OPP_ALLOW_DISTANCE
          return no

      ele = @ele

      setTranslate ele, eleMove[X], eleMove[Y]

      # 在元素上标记位移
      ele.setAttribute attr, eleMove[attr] for attr of eleMove

      @onMove.apply @, [event]


    onTouchEnd: (event) ->
      ele = @ele

      ###
      @coord = 
        "x": ele.getAttribute(X) - 0
        "y": ele.getAttribute(Y) - 0
      ###

      @onEnd.apply @, [event]


    # 初始化
    init: -> 
      @coord = "x": 0, "y": 0

      # 之所以加上下划线方法，是为了给 destroy 用
      onTouchStart = @_onTouchStart = (event) => @onTouchStart event
      onTouchMove = @_onTouchMove = (event) => @onTouchMove event
      onTouchEnd = @_onTouchEnd= (event) => @onTouchEnd event

      ele = @ele
      ele.addEventListener "touchstart", onTouchStart, no
      ele.addEventListener "touchmove", onTouchMove, no
      ele.addEventListener "touchend", onTouchEnd, no

      # 初始化元素位移
      initMove = @coord = "x": 0, "y": 0

      direction = @direction
      setTranslate ele, initMove[X], initMove[Y]

      ele.setAttribute attr, initMove[attr] for attr of initMove

      @

    # 摧毁元素的滑动
    destroy: ->

      ele = @ele
      ele.removeEventListener "touchstart", @_onTouchStart, no
      ele.removeEventListener "touchmove", @_onTouchMove, no
      ele.removeEventListener "touchend", @_onTouchEnd, no

      @



  slip = (ele, direction) ->
    instance = new Slip ele, direction or X
    instance.init()

  WIN.Slip = slip

) window, document