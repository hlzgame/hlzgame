--
-- Author: Your Name
-- Date: 2015-12-29 12:37:11
-- 事件派发类 
-- 是一个单例 用于发送 接收事件 （不同类互相联系的桥梁）

EventDispatch = class("EventDispatch",function()
	return cc.Node:create()
end)

function EventDispatch:ctor()
	self.dispatcher = self:getEventDispatcher()
	self.groupSender = {}
end

function EventDispatch:getInstance()
	if self.instance == nil then 
	   self.instance = EventDispatch.new()
	end
	return self.instance
end
