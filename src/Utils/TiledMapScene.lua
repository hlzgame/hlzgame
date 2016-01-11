--
-- Author: HLZ
-- Date: 2016-01-07 14:01:52
-- 封装一个含有TiledMap场景

TiledMapScene = class("TiledMapScene", function (  )
	return cc.Scene:create()
end)
TiledMapScene.__index = TiledMapScene

TiledMapScene.LEFT = 1
TiledMapScene.RIGHT = 2
TiledMapScene.UP = 3
TiledMapScene.DOWN = 4

--[[
    继承于 EventScene的类，需要在ctor() onEnter() onExit() 加上 .super.ctor(self)类似的方法 
--]]

function TiledMapScene:ctor()
	
	--当前场景监听的事件数组
	self.eventListeners = {}

	self.tiledMap = nil 
    
    --进入时，调用onEnter() 
    --退出时，调用onExit()
	self:registerScriptHandler(function ( event )
		if event == "enter" then
			self:onEnter()
		elseif event == "exit" then
			self:onExit()
		end
	end)
    
	self:setName(self.__cname)
	--poi?
	--self.hasPoped = false
end

function TiledMapScene:dispatchEvent(event,data)
	g_EventDispatch:dispatchEvent(event,data)
end

function TiledMapScene:registerEvent( event,callBack,groupID,priority )
	--将事件加入数组，方便在退出的时候将侦听事件给移除掉
	self.eventListeners = self.eventListeners or {}
	self.eventListeners[#self.eventListeners + 1] = g_EventDispatch:registerEvent(event,callBack,groupID,priority)
	return self.eventListeners[#self.eventListeners + 1]
end

function TiledMapScene:onExit( )
	if self.eventListeners == nil then
		return 
	end
	--统一对事件数组里面的时间进行释放
	for i,v in ipairs(self.eventListeners) do
		g_EventDispatch:removeEvent(v)
	end

	self:removeTouchListener()
	--self:_removeTimer();
	
end

function TiledMapScene:onEnter( )
	
end

function TiledMapScene:onHide(  )
	
end

--创建TiledMap
function TiledMapScene:createTMXTM(file)
	if self.tiledMap == nil then 
	   self.tiledMap = cc.TMXTiledMap:create(file)
    end

    self.maxWidth = self.tiledMap:getContentSize().width - GameUtil:VISIBLE_WIDTH()/2
    self.maxHeight = self.tiledMap:getContentSize().height - GameUtil:VISIBLE_HEIGHT()/2
    
    return self.tiledMap
end

function TiledMapScene:getLayer(layerName)
    return self.tiledMap:getLayer(layerName)
end


  --转tilemap地图      从世界地图坐标转到TiledMap地图坐标
function TiledMapScene:tileCoordForPosition(position) 
	local x = math.floor(position.x / self.tiledMap:getTileSize().width)
	local y = math.floor(((self.tiledMap:getMapSize().height * self.tiledMap:getTileSize().height)-position.y) / self.tiledMap:getTileSize().height)
	return cc.p(x,y)
end

  --转正常地图         从TiledMap地图坐标转到世界地图坐标
function TiledMapScene:positionForTileCoord(tileCoord)
	local x = math.floor((tileCoord.x * self.tiledMap:getTileSize().width) + self.tiledMap:getTileSize().width / 2)
	local y = math.floor((self.tiledMap:getMapSize().height * self.tiledMap:getTileSize().height) -
		(tileCoord.y * self.tiledMap:getTileSize().height) - self.tiledMap:getTileSize().height / 2)
	return cc.p(x, y)
end


--[[
    参数:
	[1] fieldOfView 相机视野 0~p (即 0~180 度) 之间
	[2] aspectRatio 屏幕的高宽比
	[3] nearPlane 第三个参数是与近平面的距离,请注意距离比与近平面还近的内容都不会呈现在游戏窗口中
	[4] farPlane 第四个参数是与远平面的距离，请注意距离比与远平面还远的内容都不会呈现在游戏窗口中。


	关于相机的知识：
	    默认相机的cameraFlag 为 1 
	    自己设定的相机 cameraFlag 依次增大 
	    在图形渲染的过程中 会把所有的相机能看到的图形都渲染一遍，但是这个渲染是有顺序的；
	    从cameraFlag按从大到小的顺序去渲染，所以如果想要在自己设定的相机下面去固定一个相机的话，则需要再创建一个 

	    从最底层 到 最上层 需要的相机分别是：
            不动的背景层     需要移动的TiledMap层   不需要移动的UI层
	          camera2             camera1             defaultcamera
	    cc.CameraFlag.USER2  cc.CameraFlag.USER1      cameraFlag = 1

	    =-= 如果不需要背景的话 则只需要创建一个新相机 就可以了； 如果需求是这样的话，就要创建两个新相机了；
--]]

--创建背景相机
function TiledMapScene:setBackgroundCamera(node)
	
	if self.backgroundCamera == nil then

        self.backgroundCamera = cc.Camera:createPerspective(60, GameUtil:VISIBLE_WIDTH() / GameUtil:VISIBLE_HEIGHT(), 1, 1000)
        self.backgroundCamera:setCameraFlag(cc.CameraFlag.USER2)
        node:addChild(self.backgroundCamera)

        local pos3D = node:getPosition3D()

        self.backgroundCamera:setPosition3D(cc.vec3(0, 0, 550))

        self.backgroundCamera:lookAt(cc.vec3(0,0,0), cc.vec3(0,1,0))
        self.backgroundCamera:setPosition(cc.p(GameUtil:VISIBLE_WIDTH()/2,GameUtil:VISIBLE_HEIGHT()/2))

        node:setCameraMask(cc.CameraFlag.USER2)
    end
    
    return self.backgroundCamera

end

--创建地图相机
function TiledMapScene:setMapCamera(node)
	
	if self.mapCamera == nil then

        self.mapCamera = cc.Camera:createPerspective(60, GameUtil:VISIBLE_WIDTH() / GameUtil:VISIBLE_HEIGHT(), 1, 1000)
        self.mapCamera:setCameraFlag(cc.CameraFlag.USER1)

        node:addChild(self.mapCamera)

        local pos3D = node:getPosition3D()

        self.mapCamera:setPosition3D(cc.vec3(0, 0, 550))

        self.mapCamera:lookAt(cc.vec3(0,0,0), cc.vec3(0,1,0))
        self.mapCamera:setPosition(cc.p(GameUtil:VISIBLE_WIDTH()/2,GameUtil:VISIBLE_HEIGHT()/2))

        node:setCameraMask(cc.CameraFlag.USER1)
    end
    
    return self.mapCamera

end

-- --刷新角色坐标信息
-- function TiledMapScene:refershPlayerPosInfo(speed,player,layer,direction)
    
-- end
--刷新角色坐标信息
function TiledMapScene:refershPlayerPosInfo(speed,player,layer,direction)

	
	switch(direction) : caseof
	{
	 [TiledMapScene.LEFT]  = function()   -- 向左移动
	      if self:wallDetection(direction,player,layer) == true then 
             player:setPositionX(player:getPositionX() + speed)
	      end
	  end,
	 [TiledMapScene.RIGHT] = function()   -- 向右移动
	      if self:wallDetection(direction,player,layer) == true then 
             player:setPositionX(player:getPositionX() + speed)
	      end 
	  end,
	 [TiledMapScene.UP]    = function()   -- 向上移动
	  	  if self:wallDetection(direction,player,layer) == true then 
             player:setPositionY(player:getPositionY() + speed)
	      end 
	  end,
	 [TiledMapScene.DOWN]  = function()   -- 向下移动
	  	  if self:wallDetection(direction,player,layer) == true then 
             player:setPositionY(player:getPositionY() + speed)
	      end   
	  end,
    }
    self:refreshPlayerAndCamera(speed,player)

end


--刷新玩家和相机的间距，保持一定的距离显示
--这里没有问题了 =。= 宝宝修好了
function TiledMapScene:refreshPlayerAndCamera(speed,player)

	local mapCameraPosX = self.mapCamera:getPositionX()
	local mapCameraPosY = self.mapCamera:getPositionY()
    local distanceX = mapCameraPosX - player:getPositionX()
    local distanceY = mapCameraPosY - player:getPositionY()

    if math.abs(distanceX) > GameUtil:VISIBLE_WIDTH()/4 and distanceX > 0 then 
       --需要判断方向
       if player:getPositionX() < mapCameraPosX then  --在左边
       	  self:setCameraPosX(-1,math.abs(speed))
       end
    elseif math.abs(distanceX) > GameUtil:VISIBLE_WIDTH()/4 and distanceX < 0 then
        if player:getPositionX() >= mapCameraPosX then  --在右边                                                               
          self:setCameraPosX(1,math.abs(speed))
        end
    end

    if math.abs(distanceY) > GameUtil:VISIBLE_HEIGHT()/4 and distanceY > 0 then 
       --需要判断方向
       if player:getPositionY() < mapCameraPosY then    --在下边
          self:setCameraPosY(-1,math.abs(speed))
       end
    elseif math.abs(distanceY) > GameUtil:VISIBLE_HEIGHT()/4 and distanceY < 0 then
        if player:getPositionY() >= mapCameraPosY then  --在上边                                                             
          self:setCameraPosY(1,math.abs(speed))
        end
    end
   
end

--移动地图相机X轴
function TiledMapScene:setCameraPosX(direction,x)
	local distanceX = direction * x
	local nowPosX = self.mapCamera:getPositionX() + distanceX
	if ((nowPosX < GameUtil:VISIBLE_WIDTH()/2) and direction == -1 ) or ((nowPosX > self.maxWidth) and direction == 1 ) then 
		return 
	end
	self.mapCamera:setPositionX(nowPosX)
end

--移动地图相机Y轴
function TiledMapScene:setCameraPosY(direction,y)
	local distanceY = direction * y
	local nowPosY = self.mapCamera:getPositionY() + distanceY
	if ((nowPosY < GameUtil:VISIBLE_HEIGHT()/2) and direction == -1 ) or ((nowPosY > self.maxHeight) and direction == 1 ) then 
		return 
	end
    self.mapCamera:setPositionY(nowPosY)
end


--检测墙壁 不会自由下落 不能移动
--需要在移动之前进行判断
--[[根据传进来的玩家，获取玩家的TiledMap坐标，然后判断脚下那一格是否是墙壁]]
function TiledMapScene:wallDetection(direction,player,layer)
    local playerPosX = player:getPositionX()
    local playerPosY = player:getPositionY()

    local playerTiledMapPos = self:tileCoordForPosition(cc.p(playerPosX,playerPosY))

    local aX,aY = 0,0

    switch(direction) : caseof
	{
	 [TiledMapScene.LEFT]  = function() aX,aY = -1, 0  end,
	 [TiledMapScene.RIGHT] = function() aX,aY =  1, 0  end,
	 [TiledMapScene.UP]    = function() aX,aY =  0,-2  end,
	 [TiledMapScene.DOWN]  = function() aX,aY =  0, 1  end,
    }

    local wallPos = cc.p(playerTiledMapPos.x + aX,playerTiledMapPos.y+aY)

    local gid = layer:getTileGIDAt(wallPos)

    if gid == 0 then 
       print("没墙，安心撞")
       return true
    else
       print("有墙，慢慢撞")
       return false
    end
end


function TiledMapScene:initTouchListener( bSwallow )
	-- if bSwallow == nil then
	-- 	bSwallow = false
	-- end
	-- local function TouchBegan( touch,event )
	-- 	local location = touch:getLocation()
	-- 	return self:onTouchBegan(location.x,location.y)
	-- end
	-- local function TouchMoved( touch,event )
	-- 	local location = touch:getLocation()
	-- 	self:onTouchMoved(location.x,location.y)
	-- end
	-- local function TouchEnded( touch,event )
	-- 	local location = touch:getLocation()
	-- 	self:onTouchEnded(location.x,location.y)
	-- end
	-- local function TouchCancelled( touch,event )
	-- 	local location = touch:getLocation()
	-- 	self:onTouchCancelled(location.x,location.y)
	-- end
	-- local listener = cc.EventListenerTouchOneByOne:create()
 --    listener:registerScriptHandler(TouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
 --    listener:registerScriptHandler(TouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
 --    listener:registerScriptHandler(TouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
 --    listener:registerScriptHandler(TouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
 --    listener:setSwallowTouches(bSwallow)
 --    local eventDispatcher = self:getEventDispatcher()
 --    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
 --    self._listener = listener

end

--初始化键盘响应事件
function TiledMapScene:initKeyBoardListener()
        --按下事件
	    local function keyboardPressed(keyCode, event)
	        if keyCode == cc.KeyCode.KEY_LEFT_ARROW then
	            self:pressedLeftBtnListener()
	        elseif keyCode == cc.KeyCode.KEY_RIGHT_ARROW then
	            self:pressedRightBtnListener()
	        elseif keyCode == cc.KeyCode.KEY_UP_ARROW then
	            self:pressedUpBtnListener()
	        elseif keyCode == cc.KeyCode.KEY_DOWN_ARROW then
	            self:pressedDownBtnListener()
	        end
	        -- print("keyCode = "..tostring(keyCode))
	        -- print("event = "..tostring(event))
        end
        
        --松开事件
        local function keyboardReleased(keyCode, event)
	        if keyCode == cc.KeyCode.KEY_LEFT_ARROW then
	            self:releasedLeftBtnListener()
	        elseif keyCode == cc.KeyCode.KEY_RIGHT_ARROW then
	            self:releasedRightBtnListener()
	        elseif keyCode == cc.KeyCode.KEY_UP_ARROW then
	            self:releasedUpBtnListener()
	        elseif keyCode == cc.KeyCode.KEY_DOWN_ARROW then
	            self:releasedDownBtnListener()
	        end

	        -- print("keyCode = "..tostring(keyCode))
	        -- print("event = "..tostring(event))
        end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(keyboardReleased,cc.Handler.EVENT_KEYBOARD_RELEASED)
    

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
    self._listener = listener

end

function TiledMapScene:removeTouchListener(  )
	if self._listener then 
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListener(self._listener)
		self._listener = nil
    end
end

--按下事件
function TiledMapScene:pressedLeftBtnListener()

end

function TiledMapScene:pressedRightBtnListener()

end

function TiledMapScene:pressedUpBtnListener()

end

function TiledMapScene:pressedDownBtnListener()

end



--松开事件
function TiledMapScene:releasedLeftBtnListener()

end

function TiledMapScene:releasedRightBtnListener()

end

function TiledMapScene:releasedUpBtnListener()

end

function TiledMapScene:releasedDownBtnListener()

end

--[[

    用的到的一些TiledMap地图的方法 

    设置一个地图块:     layer:setTileGID(GID, cc.p(x,y)) 
    获得一个地图块的GID layer:getTileGIDAt(cc.p(x,y))
    移除一个地图块：    layer:removeTileAt(cc.p(x,y))
    获得当前地图的每块地图的长宽  getMapSize().height   getMapSize().width
   
--]]


