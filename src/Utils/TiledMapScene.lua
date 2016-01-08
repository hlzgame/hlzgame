--
-- Author: HLZ
-- Date: 2016-01-07 14:01:52
-- 封装一个含有TiledMap场景

TiledMapScene = class("TiledMapScene", function (  )
	return cc.Scene:create()
end)
TiledMapScene.__index = TiledMapScene

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
	--self:_removeTimer();
	
end

function TiledMapScene:onEnter( )
	
end

function TiledMapScene:onHide(  )
	
end

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
function TiledMapScene:tileCoordForPosition(tileMap,position) 
	local x = math.floor(position.x / tileMap:getTileSize().width)
	local y = math.floor(((tileMap:getMapSize().height * tileMap:getTileSize().height)-position.y) / tileMap:getTileSize().height)
	return cc.p(x,y)
end

  --转正常地图         从TiledMap地图坐标转到世界地图坐标
function TiledMapScene:positionForTileCoord(tileMap,tileCoord)
	local x = math.floor((tileCoord.x * tileMap:getTileSize().width) + tileMap:getTileSize().width / 2)
	local y = math.floor((tileMap:getMapSize().height * tileMap:getTileSize().height) -
		(tileCoord.y * tileMap:getTileSize().height) - tileMap:getTileSize().height / 2)
	return cc.p(x, y)
end


--[[
    参数:
	[1] fieldOfView 相机视野 0~p (即 0~180 度) 之间
	[2] aspectRatio 屏幕的高宽比
	[3] nearPlane 第三个参数是与近平面的距离,请注意距离比与近平面还近的内容都不会呈现在游戏窗口中
	[4] farPlane 第四个参数是与远平面的距离，请注意距离比与远平面还远的内容都不会呈现在游戏窗口中。
--]]

function TiledMapScene:setCamera(scene)
	--创建唯一相机
	if self.camera == nil then

        self.camera = cc.Camera:createPerspective(60, GameUtil:VISIBLE_WIDTH() / GameUtil:VISIBLE_HEIGHT(), 1, 1000)
        self.camera:setCameraFlag(cc.CameraFlag.USER1)
        scene:addChild(self.camera)
        --self.camera:setPosition3D(cc.vec3(0, 0, 10))
        local pos3D = scene:getPosition3D()
        dump(pos3D)
        --self.camera:setPosition3D(cc.vec3(0 + pos3D.x, 130 + pos3D.y, 130 + pos3D.z))
        self.camera:setPosition3D(cc.vec3(0, 0, 550))
        self.camera:lookAt(cc.vec3(0,0,0), cc.vec3(0,1,0))
        self.camera:setPosition(cc.p(GameUtil:VISIBLE_WIDTH()/2,GameUtil:VISIBLE_HEIGHT()/2))

        dump(self.camera:getPosition())
    end
    scene:setCameraMask(2)

    return self.camera

end

function TiledMapScene:setCameraPosX(direction,x)
	local distanceX = direction * x
	local nowPosX = self.camera:getPositionX() + distanceX
	if ((nowPosX < GameUtil:VISIBLE_WIDTH()/2) and direction == -1 ) or ((nowPosX > self.maxWidth) and direction == 1 ) then 
		return 
	end
	self.camera:setPositionX(nowPosX)
end

function TiledMapScene:setCameraPosY(direction,y)
	local distanceY = direction * y
	local nowPosY = self.camera:getPositionY() + distanceY
	if ((nowPosY < GameUtil:VISIBLE_HEIGHT()/2) and direction == -1 ) or ((nowPosY > self.maxHeight) and direction == 1 ) then 
		return 
	end
    self.camera:setPositionY(nowPosY)
end
--[[

    用的到的一些TiledMap地图的方法 

    设置一个地图块:     layer:setTileGID(GID, cc.p(x,y)) 
    获得一个地图块的GID layer:getTileGIDAt(cc.p(x,y))
    移除一个地图块：    layer:removeTileAt(cc.p(x,y))
    获得当前地图的每块地图的长宽  getMapSize().height   getMapSize().width
    


--]]


