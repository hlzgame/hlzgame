--
-- Author: HLZ
-- Date: 2016-01-07 20:19:31
-- 玩家角色视图节点


--[[
    玩家自身的一个节点

--]]
PlayerView = class("PlayerView",EventNode)

function PlayerView:ctor()
	PlayerView.super.ctor(self)

	local sprite = cc.Sprite:create("publish/resource/2.jpg")
	self:addChild(sprite)
    
    --父场景
	self.parentScene = nil 
end

function PlayerView:getTiledMapScene(scene)
    self.parentScene = scene
end

function PlayerView:onEnter()
    PlayerView.super.onEnter(self)
end

function PlayerView:onExit()
    PlayerView.super.onExit(self)
end
