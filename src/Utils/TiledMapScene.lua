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
    return self.tiledMap
end

function TiledMapScene:getLayer(layerName)
    return self.tiledMap:getLayer(layerName)
end

--[[

    用的到的一些TiledMap地图的方法 

    设置一个地图块:     layer:setTileGID(GID, cc.p(x,y)) 
    获得一个地图块的GID layer:getTileGIDAt(cc.p(x,y))
    移除一个地图块：    layer:removeTileAt(cc.p(x,y))
    获得当前地图的每块地图的长宽  getMapSize().height   getMapSize().width
    
      --转tilemap地图
	function TileMap:tileCoordForPosition(position) 
		local x = math.floor(position.x / self._tileMap:getTileSize().width)
		local y = math.floor(((self._tileMap:getMapSize().height * self._tileMap:getTileSize().height)-position.y) / self._tileMap:getTileSize().height)
		return cc.p(x,y)
	end

	  --转正常地图
	function TileMap:positionForTileCoord(tileCoord)
		local x = math.floor((tileCoord.x * self._tileMap:getTileSize().width) + self._tileMap:getTileSize().width / 2)
		local y = math.floor((self._tileMap:getMapSize().height * self._tileMap:getTileSize().height) -
			(tileCoord.y * self._tileMap:getTileSize().height) - self._tileMap:getTileSize().height / 2)
		return cc.p(x, y);
	end

--]]


