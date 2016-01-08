--
-- Author: Your Name
-- Date: 2016-01-08 10:51:13
-- 主角节点封装

PlayerNode = class("PlayerNode",function ()
	return cc.Node:create()
end)

PlayerNode.__index = PlayerNode

--[[
    继承于 PlayerNode的类，需要在ctor() onEnter() onExit() 加上 .super.ctor(self)类似的方法 
    在该类中 封装 相机系统
    enum class CameraFlag
	{
	    DEFAULT = 1,
	    USER1 = 1 << 1,
	    USER2 = 1 << 2,
	    USER3 = 1 << 3,
	    USER4 = 1 << 4,
	    USER5 = 1 << 5,
	    USER6 = 1 << 6,
	    USER7 = 1 << 7,
	    USER8 = 1 << 8,
	};
--]]

function PlayerNode:ctor()
	

   
    --进入时，调用onEnter() 
    --退出时，调用onExit()
	self:registerScriptHandler(function ( event )
		if event == "enter" then
			self:onEnter()
		elseif event == "exit" then
			self:onExit()
		end
	end)

    --当前场景监听的事件数组
	self.eventListeners = {}

    self.isPause = false
	--相机
	self.camera = nil 
    
    

	self:setName(self.__cname)

end

function PlayerNode:dispatchEvent(event,data)
	g_EventDispatch:dispatchEvent(event,data)
end

function PlayerNode:setCamera(node)
	--创建唯一相机
	self.node = node 
	if self.camera == nil then
        self.camera = cc.Camera:createPerspective(60, 1136 / 640, 1, 1000)
        self.camera:setCameraFlag(cc.CameraFlag.USER1)
        self.node:addChild(self.camera)
        --self.camera:setPosition3D(cc.vec3(0, 0, 10))
        local pos3D = self.node:getPosition3D()

        --self.camera:setPosition3D(cc.vec3(0 + pos3D.x, 130 + pos3D.y, 130 + pos3D.z))
        self.camera:setPosition3D(cc.vec3(0, 0, 500))
        self.camera:lookAt(cc.vec3(0,0,-1), cc.vec3(0,1,0))

        dump(self.camera:getPosition3D())
    end
    self.node:setCameraMask(2)

    -- if self.updateHandler ~= nil then 
    -- 	g_scheduler:unscheduleScriptEntry(self.updateHandler)
    -- 	self.updateHandler = nil 
    -- end

    -- self.updateHandler = g_scheduler:scheduleScriptFunc(self:update(),0, false);

    return self.camera

end

-- function PlayerNode:update()
--     if self.isPause == true then
--         return nil
--     end
  
--     self.camera:setPositionX(self.node:getPositionX() - 180)
--     self.camera:setPositionY(self.node:getPositionY() - 180)

-- end


function PlayerNode:registerEvent( event,callBack,groupID,priority )
	--将事件加入数组，方便在退出的时候将侦听事件给移除掉
	self.eventListeners = self.eventListeners or {}
	self.eventListeners[#self.eventListeners + 1] = g_EventDispatch:registerEvent(event,callBack,groupID,priority)
	return self.eventListeners[#self.eventListeners + 1]
end

function PlayerNode:onExit( )
	if self.eventListeners == nil then
		return 
	end
	--统一对事件数组里面的时间进行释放
	for i,v in ipairs(self.eventListeners) do
		g_EventDispatch:removeEvent(v)
	end	
end

function PlayerNode:onEnter( )
	
end

function PlayerNode:onHide(  )
	
end