--
-- Author: HLZ
-- Date: 2016-01-07 20:21:58
-- 玩家基本信息类

PlayerBaseInfo = class("PlayerBaseInfo")

function PlayerBaseInfo:ctor( data )
	self.playerName = ""

	--玩家基本属性数值
	--[[
        基础一级属性：
                     攻击
                     速度
                     能量
                     弹跳力
                     弹跳高度
	--]]
	self.powerValue = 0
	self.speedValue = 5 
	self.energyValue = 0
	self.jumpValue = 5
	self.jumpHeight = 100
end

function PlayerBaseInfo:setPlayerBaseInfo(data)

end

function PlayerBaseInfo:getPlayerPowerValue()
	return self.powerValue
end

function PlayerBaseInfo:getPlayerSpeedValue()
	return self.speedValue
end

function PlayerBaseInfo:getPlayerEnergyValue()
	return self.energyValue
end

function PlayerBaseInfo:getPlayerJumpValue()
	return self.jumpValue
end

function PlayerBaseInfo:getPlayerJumpHeight()
	return self.jumpHeight
end

