--
-- Author: Your Name
-- Date: 2016-01-08 10:51:13
-- 主角节点封装
require("Utils.StateMachine")

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
    elseif self.parentScene:wallDetection(TiledMapScene.DOWN,self) == false then  --不能下降 如果当前处于跳跃阶段，则结束跳跃阶段
       self:doEvent("stop")
    end

end

--普通向左移动
function PlayerNode:moveToLeft(distance)
   
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
    self:setPositionY(self:getPositionY() + distance)
end

--普通下蹲
function PlayerNode:commonSquat()
	
end


--初始化 动作状态机
--这里需要好好划分一下
--[[
    
	onleave red - 离开红色状态时的回调
	onleave state - 离开任何状态时的回调
	onenter green - 进入绿色状态时的回调
	onenter state - 进入任何状态时的回调

	onbefore clear - clear事件执行前的回调
	onbefore event - 任何事件执行前的回调
	onafter clear - clear事件完成之后的回调
	onafter event - 任何事件完成之后的回调

    执行顺序
	onbeforeisJump  1
    onenterjump     2
    onafterisJump   3
    onleavejump     4


    self.fsm:isReady()-返回状态机是否就绪
	self.fsm:getState()-返回当前状态
	self.fsm:isState(state)-判断当前状态是否是参数state状态
	self.fsm:canDoEvent(eventName)-当前状态如果能完成eventName对应的event的状态转换，则返回true
	self.fsm:cannotDoEvent(eventName)-当前状态如果不能完成eventName对应的event的状态转换，则返回true
	self.fsm:isFinishedState()-当前状态如果是最终状态，则返回true
	self.fsm:doEventForce(name, ...)-强制对当前状态进行转换
    
    
    状态 (暂定)
    state:

	    idle    待机 
	    --walk    走路(暂时不用这些状态)
	    --run     跑动
	    jump    跳跃
	    squat   下蹲
	    roll    滚动
	    attack  攻击
	    defend  防守
	    climb   攀爬
	    skill   特殊技能
	    

    事件
    event:

	    isJump    我要跳
	    isDrop    我要下降
	    isAttack  我要攻击
	    isSkill   我要放技能


	逻辑整理：
	isJump   在 { idle walk run climb } 可以进行 jump 
    isAttack 在 { "idle","walk","jump","run","defend","drop" } 可以进行 attack
    isSkill  在 { "idle","walk","jump","run","defend","drop" } 可以进行 skill

    关于重力：

    drop 只有在 isJump 时 关闭，其他事件都打开（以后特殊场景除外）

]]
function PlayerNode:initStateMachine( )
	self.fsm = StateMachine.new()

	self.fsm:setupState({
		initial = "idle",
		events = {
		          {name = "stop",     from = {"jump","defend","attack","skill","drop"}, to = "idle"},
		          {name = "isJump",   from = {"idle","climb"},                          to = "jump" },
			      {name = "isAttack", from = {"idle","jump","defend","drop"},           to = "attack"},
			      {name = "isSkill",  from = {"idle","jump","defend"},                  to = "skill"},
			      {name = "isDrop",   from = {"jump"},                                  to = "drop"},
			    },
        callbacks = {
				   onbeforestart = function(event) print("[FSM] STARTING UP") end,
				   onstart = function(event) print("[FSM] READY") end,
				   --在跳跃之前执行事件 关闭重力
				   onbeforeisJump = function(event) self:openOrColseGravity(false) end,				    
				   --跳跃结束之后执行事件 开启重力
				   onafterisJump  = function(event)  end,       
                   onenterjump = function(event) self:jump() end,--self:openOrColseGravity(false) end,
                   onleavejump = function(event)  end,--self:openOrColseGravity(false) end,
				   onenteridle = function(event)  end,
				   onenterdrop = function(event) self:openOrColseGravity(true) end,
				   onenterstop = function(event) self:unscheduleHandler() end,
			    },
	})
end

function PlayerNode:unscheduleHandler()
	-- body
end

--转换状态
function PlayerNode:doEvent(event,...)
	--dump(self:canDoEvent(event))
	if self:canDoEvent(event) == true then
       self.fsm:doEvent(event,...)
    end
end

--强制转换
function PlayerNode:doEventForce(event,...)
	self.fsm:doEventForce(event,...)
end

--当前状态如果能完成eventName对应的event的状态转换，则返回true
function PlayerNode:canDoEvent(event,...)
	return self.fsm:canDoEvent(event,...)
end

--当前状态如果不能完成eventName对应的event的状态转换，则返回true
function PlayerNode:cannotDoEvent(event,...)
	return self.fsm:cannotDoEvent(event,...)
end

function PlayerNode:getState()
	return self.fsm:getState()
end