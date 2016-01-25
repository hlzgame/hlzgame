--
-- Author: HLZ
-- Date: 2016-01-07 20:19:31
-- 玩家角色视图节点


--[[
    玩家自身的一个节点
--]]

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

	self.isMoveLeft = false
	self.isMoveRight = false


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
    self:doEventForce("stop")
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

    if self.parentScene:wallDetection(TiledMapScene.LEFT,self) == true and self.isMoveLeft == false  then

		local func = function ( )
	    	if self.parentScene:wallDetection(TiledMapScene.LEFT,self) == true then
		  	   self:setScaleX(-1)
			   local distance = self.speedValue/1
			   self:setPositionX(self:getPositionX() - distance)
		  	   self.parentScene:refreshPlayerAndCamera(distance,self)
		    end	
	    end

	    self:removeLeftMoveHandler()
		self.isMoveLeft = true
		self.leftMoveHandler = g_scheduler:scheduleScriptFunc(func,0,false) 

    end

end

--普通向右移动
function PlayerView:toRight()

     if self.parentScene:wallDetection(TiledMapScene.RIGHT,self) == true and self.isMoveRight == false then
		local func = function ( )	
	    	if self.parentScene:wallDetection(TiledMapScene.RIGHT,self) == true then
		  	   self:setScaleX(1)
			   local distance = self.speedValue/1
			   self:setPositionX(self:getPositionX() + distance)
		  	   self.parentScene:refreshPlayerAndCamera(distance,self)
		    end	
	    end
	    self:removeRightMoveHandler()

	    self.isMoveRight = true
		self.rightMoveHandler = g_scheduler:scheduleScriptFunc(func,0,false) 
    end

end

function PlayerView:removeRightMoveHandler()
	if self.rightMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.rightMoveHandler)
       self.rightMoveHandler = nil 
       self.isMoveRight = false
    end	
end

function PlayerView:removeLeftMoveHandler()
	if self.leftMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.leftMoveHandler)
       self.leftMoveHandler = nil 
       self.isMoveLeft = false
    end	
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

   if self.parentScene:wallDetection(TiledMapScene.JUMP,self) == true then 
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
			       self:doEvent("isDrop")
			    end
	        end

	    end

	    if self.jumpHandler ~= nil then 
	       g_scheduler:unscheduleScriptEntry(self.jumpHandler)
	       self.jumpHandler = nil 
	    end
		
		self.jumpHandler = g_scheduler:scheduleScriptFunc(func,0,false)
   else
        self:doEvent("stop")
   end

end

--普通下蹲
function PlayerView:squat()
	
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
             self:doEvent("isJump")
	      end   
	  end,
	  [TiledMapScene.SQUAT]  = function()   -- 下蹲
	  	  if self.parentScene:wallDetection(direction,self) == true then 
             
	      end   
	  end,
    }
end