--
-- Author: HLZ
-- Date: 2016-01-07 20:19:31
-- 玩家角色视图节点


--[[
    玩家自身的一个节点

--]]
require("GameLogic.Hero.PlayerBaseInfo")

PlayerView = class("PlayerView",PlayerNode)

function PlayerView:ctor()
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
	self.parentScene = nil 
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
	
end

function PlayerView:getTiledMapScene(scene)
    self.parentScene = scene
end

function PlayerView:initEvent()

end

function PlayerView:onEnter()
    PlayerView.super.onEnter(self)
end

function PlayerView:onExit()
    PlayerView.super.onExit(self)
end

--普通向左移动
function PlayerView:toLeft()
	self:setScaleX(-1)
	local distance = self.speedValue*1
	self:moveToLeft(distance)
	return distance
end

--普通向右移动
function PlayerView:toRight()
	self:setScaleX(1)
	local distance = self.speedValue*1
	self:moveToRight(distance)
	return distance
end

--普通跳跃
function PlayerView:jump() 
   self:setPositionY(self:getPositionY() + self.jumpValue)
end

--普通下蹲
function PlayerView:squat()
	
end