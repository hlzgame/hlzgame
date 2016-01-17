--
-- Author: HLZ
-- Date: 2016-01-07 20:19:31
-- 玩家角色视图节点


--[[
    玩家自身的一个节点
--]]
require("Utils.StateMachine")

require("GameLogic.Hero.PlayerBaseInfo")

PlayerView = class("PlayerView",PlayerNode)

function PlayerView:ctor(parent)
	PlayerView.super.ctor(self)

	local sprite = cc.Sprite:create("publish/resource/player.png")
	self:addChild(sprite)
	sprite:setAnchorPoint(cc.p(0.5,0.5))
	sprite:setPositionY(32)

	--设置节点
   

	print("PlayerView")
	dump(sprite:getPosition())
    
    self:initPlayer()
    --父场景
	self.parentScene = parent 
	self:setParentScene(parent)


end



function PlayerView:initPlayer()

	--初始化玩家信息 以后可能是在加载中进行数据加载
	local data = {}
	self.playerInfo = PlayerBaseInfo.new()
	self.playerInfo:setPlayerBaseInfo(data)

    self.powerValue = self.playerInfo:getPlayerPowerValue()
    self.speedValue = self.playerInfo:getPlayerSpeedValue()
    self.energyValue = self.playerInfo:getPlayerEnergyValue()
    self.jumpValue = self.playerInfo:getPlayerJumpValue()
	self.jumpHeight = self.playerInfo:getPlayerJumpHeight()

	self:initStateMachine()
end


function PlayerView:initEvent()

end

function PlayerView:onEnter()
    PlayerView.super.onEnter(self)
end

function PlayerView:onExit()
    PlayerView.super.onExit(self)
end

function PlayerView:openOrColseGravity(flag)
	self:setGravity(flag)
	if flag == true then 
       self:openGravity()
	else
       if self.gravityHandler ~= nil then 
	       g_scheduler:unscheduleScriptEntry(self.gravityHandler)
	       self.gravityHandler = nil 
	    end
	end
	-- body
end

--普通向左移动
function PlayerView:toLeft()
	self:setScaleX(-1)
	local distance = self.speedValue/1
	self:moveToLeft(distance)
	return distance
end

--普通向右移动
function PlayerView:toRight()
	self:setScaleX(1)
	local distance = self.speedValue/1
	self:moveToRight(distance)
	return distance
end

--普通向上移动
function PlayerView:toUp()
	local distance = self.speedValue/2
	self:moveToUp(distance)
	return distance
end

--普通向下移动
function PlayerView:toDown()
	local distance = self.speedValue/2
	self:moveToDown(distance)
	return distance
end

function PlayerView:openGravity()
	
	if self:getIsGravity() == true then 

        local distance = self.jumpValue/1

        local func = function ( )
	       	self:fallWithGravity(distance)     
	    end
		
		self.gravityHandler = g_scheduler:scheduleScriptFunc(func,0,false) 
	else
	    if self.gravityHandler ~= nil then 
	       g_scheduler:unscheduleScriptEntry(self.gravityHandler)
	       self.gravityHandler = nil 
	    end
    end
end

--普通跳跃
function PlayerView:jump()
    if self:getIsJump() == false then 
       self:setIsJump(true)
       self:openOrColseGravity(false)
       local distance = self.jumpValue*2
       local jumpHeight = self:getPositionY() + self.jumpHeight

       local func = function ( )
            --print("self:getPositionY():"..self:getPositionY().."   jumpHeight:"..jumpHeight)
	        if self:getPositionY() <= jumpHeight and self.parentScene:wallDetection(TiledMapScene.JUMP,self) == true then
	        	
	            self:setPositionY(self:getPositionY() + distance)
	            self.parentScene:refreshPlayerAndCamera(distance,self)
	        else
	            if self.jumpHandler ~= nil then 
			       g_scheduler:unscheduleScriptEntry(self.jumpHandler)
			       self.jumpHandler = nil 
			       self:openOrColseGravity(true)
			    end
	        end

	    end

	    if self.jumpHandler ~= nil then 
	       g_scheduler:unscheduleScriptEntry(self.jumpHandler)
	       self.jumpHandler = nil 
	    end
		
		self.jumpHandler = g_scheduler:scheduleScriptFunc(func,0,false) 
    end

    --
end

--普通下蹲
function PlayerView:squat()
	
end

--初始化 动作状态机
--这里需要好好划分一下
--[[
    onbefore clear - clear事件执行前的回调
	onbefore event - 任何事件执行前的回调
	onleave red - 离开红色状态时的回调
	onleave state - 离开任何状态时的回调
	onenter green - 进入绿色状态时的回调
	onenter state - 进入任何状态时的回调
	onafter clear - clear事件完成之后的回调
	onafter event - 任何事件完成之后的回调


    self.fsm:isReady()-返回状态机是否就绪
	self.fsm:getState()-返回当前状态
	self.fsm:isState(state)-判断当前状态是否是参数state状态
	self.fsm:canDoEvent(eventName)-当前状态如果能完成eventName对应的event的状态转换，则返回true
	self.fsm:cannotDoEvent(eventName)-当前状态如果不能完成eventName对应的event的状态转换，则返回true
	self.fsm:isFinishedState()-当前状态如果是最终状态，则返回true
	self.fsm:doEventForce(name, ...)-强制对当前状态进行转换


]]
function PlayerView:initStateMachine( )
	self.fsm = StateMachine.new()

	self.fsm:setupState({
		initial = "green",
		events = {
		          {name = "warn",from = "green",to = "yellow"},
		          {name = "panic", from = "green", to = "red" },
			      {name = "calm", from = "red", to = "yellow"},
			      {name = "clear", from = "yellow", to = "green"      },
			    },
        callbacks = {
	    onbeforestart = function(event) print("[FSM] STARTING UP") end,
	    onstart = function(event) print("[FSM] READY") end,
	    onbeforewarn = function(event) print("[FSM] START EVENT: warn!") end,
	    onbeforepanic = function(event) print("[FSM] START EVENT: panic!") end,
	    onbeforecalm = function(event) print("[FSM] START EVENT: calm!") end,
	    onbeforeclear = function(event) print("[FSM] START EVENT: clear!") end,
	    onwarn = function(event) print("[FSM] FINISH EVENT: warn!") end, },
	})
	self.fsm:doEvent("warn")
end

function PlayerView:refershPos(direction)
	local distance = 0 

	switch(direction) : caseof
	{
	 [TiledMapScene.LEFT]  = function()   -- 向左移动
	      if self.parentScene:wallDetection(direction,self) == true then 
	      	 distance = self:toLeft()   -- 返回位移偏移值
	      	 self.parentScene:refreshPlayerAndCamera(distance,self)
	      end
	  end,
	 [TiledMapScene.RIGHT] = function()   -- 向右移动
	      if self.parentScene:wallDetection(direction,self) == true then 
	      	 distance = self:toRight()
	      	 self.parentScene:refreshPlayerAndCamera(distance,self)
	      end 
	  end,
	 [TiledMapScene.UP]    = function()   -- 向上移动
	  	  if self.parentScene:wallDetection(direction,self) == true then 
             distance = self:toUp()
             self.parentScene:refreshPlayerAndCamera(distance,self)
	      end 
	  end,
	 [TiledMapScene.DOWN]  = function()   -- 向下移动
	  	  if self.parentScene:wallDetection(direction,self) == true then 
             distance = self:toDown()
             self.parentScene:refreshPlayerAndCamera(distance,self)
	      end   
	  end,
	  [TiledMapScene.JUMP]  = function()   -- 跳跃
	  	  --跳跃是一个持续的过程，在这个期间 需要不断的进行碰撞判断
          if self.parentScene:wallDetection(direction,self) == true then 
              self:jump()
	      end   
	  end,
	  [TiledMapScene.SQUAT]  = function()   -- 下蹲
	  	  if self.parentScene:wallDetection(direction,self) == true then 
             
	      end   
	  end,
    }
end