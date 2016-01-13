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

    --是否处于跳跃状态
	self.isJump = false
	--是否处于重力状态
	self.gravity = false
    
    self:setCameraMask(2)

	self:setName(self.__cname)

end

function PlayerNode:dispatchEvent(event,data)
	g_EventDispatch:dispatchEvent(event,data)
end


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

function PlayerNode:setIsJump(flag)
	self.isJump = flag
end

function PlayerNode:getIsJump()
	return self.isJump 
end

function PlayerNode:setParentScene(parent)
	self.parentScene = parent
end

function PlayerNode:setGravity(flag)
    self.gravity = flag
end

function PlayerNode:getIsGravity()
	return self.gravity
end

function PlayerNode:fallWithGravity(gravity)
	--是恒定下降速度 还是加上重力加速度
  
    if self.parentScene:wallDetection(TiledMapScene.DOWN,self) == true then --可以下降
       self:setPositionY(self:getPositionY() - gravity)
       self.parentScene:refreshPlayerAndCamera(gravity,self)
       
    else  --不能下降 如果当前处于跳跃阶段，则结束跳跃阶段
       if self:getIsJump() == true then 
       	  self:setIsJump(false)
       end
    end

end

--普通向左移动
function PlayerNode:moveToLeft(distance)
   self:setPositionX(self:getPositionX() - distance)
end

--普通向右移动
function PlayerNode:moveToRight(distance)
	self:setPositionX(self:getPositionX() + distance)
end

--普通向上移动
function PlayerNode:moveToUp(distance)
   self:setPositionY(self:getPositionY() + distance)
end

--普通向下移动
function PlayerNode:moveToDown(distance)
	self:setPositionY(self:getPositionY() - distance)
end

--普通跳跃
function PlayerNode:commonJump(distance) 
	print("------"..distance)
    self:setPositionY(self:getPositionY() + distance)
end

--普通下蹲
function PlayerNode:commonSquat()
	
end