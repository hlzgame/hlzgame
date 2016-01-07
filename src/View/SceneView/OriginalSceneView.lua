--
-- Author: HLZ
-- Date: 2016-01-06 14:02:56
-- 初始之地场景


--[[
     玩家在这里  进行重生
     并且在这里  进行点数（记忆碎片）购买
     还可以扩展  更多的功能性
--]]

require("View.Hero.PlayerView")

OriginalSceneView = class("OriginalSceneView",TiledMapScene)


function OriginalSceneView:ctor()
	OriginalSceneView.super.ctor(self)
end

function OriginalSceneView:initScene()
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self)
    else
        cc.Director:getInstance():runWithScene(self)
    end
    self:initEvent()
    self:initTileMap()
end

function OriginalSceneView:initEvent()
    -- self:registerEvent(TEST_EVENT_RETURN,function(event)
    --     print("TEST_EVENT_RETURN")
    -- end)
end

function OriginalSceneView:initTileMap()
	--加载地图
	self.map = self:createTMXTM(ORIGINAL_SCENCE_TMX)
    self:addChild(self.map,5)
    self.map:setAnchorPoint(cc.p(0,0))
    self.map:setPosition(cc.p(0,0))

    --加载背景图片

    self.guiNode = createGUINode(res.RES_BACKGROUND_ORIGINAL)
    self:addChild(self.guiNode)
    

    self.impactLayer = self:getLayer(IMPACT_LAYER)
    self.impactLayer:setVisible(false)

    local pos = self:tileCoordForPosition(self.map,cc.p(0,1))
    dump(pos)

    local player = PlayerView.new()

    self.map:addChild(player)

    player:setPosition(self:positionForTileCoord(self.map,cc.p(1,28)))
end

function OriginalSceneView:onEnter()
	OriginalSceneView.super.onEnter(self)
    print("onEnter")

    --self:initScene()
end

function OriginalSceneView:onExit()
	OriginalSceneView.super.onExit(self)
    print("onExit")
end

function OriginalSceneView.open()
	local view = OriginalSceneView.new()
	view:initScene()
	--这里以后肯定要进行特殊处理
end

