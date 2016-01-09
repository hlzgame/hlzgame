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

    --加载背景图片
    self.guiNode = cc.Sprite:create("publish/resource/bg.png")--createGUINode(res.RES_BACKGROUND_ORIGINAL)
    self.guiNode:setName("self.guiNode")
    --self.guiNode:setCameraMask(cc.CameraFlag.USER1)
    self:addChild(self.guiNode)
    --self.guiNode:setVisible(false)
    --dump(cc.Camera:getDefaultCamera():getPosition())


    --加载地图
	self.map = self:createTMXTM(ORIGINAL_SCENCE_TMX)
	self.map:setName("self.map")
    self:addChild(self.map,5)
    self.map:setAnchorPoint(cc.p(0,0))    
    self.map:setCameraMask(cc.CameraFlag.USER1)
    --self.map:setPosition(cc.p(0,0))

       
    self.impactLayer = self:getLayer(IMPACT_LAYER)
    --self.backGroundLayer = self:getLayer(BACKGROUND_LAYER)
    self.impactLayer:setVisible(false)

    self.player = PlayerView.new()
    --self.player:setCameraMask(cc.CameraFlag.USER1)
    self.map:addChild(self.player,10)

   

    self.initPlayerPos = self:positionForTileCoord(self.map,cc.p(12,28))

    self.player:setPosition(self.initPlayerPos)

    if self.updateBattle ~= nil  then
        g_scheduler:unscheduleScriptEntry(self.updateBattle);
        self.updateBattle = nil 
    end

    self.camera = self:setCamera(self)

    local func = function ()

        self.speed = 0.1
        self.player:setPositionX(self.player:getPositionX() + self.speed*10)
        self.player:setPositionY(self.player:getPositionY() + self.speed*10)


        self:refreshPlayerAndCamera()
        
    end

    
    --self.updateBattle = g_scheduler:scheduleScriptFunc(func, 0, false);
    
    --开启触摸
    self:initTouchListener()

    
end

function OriginalSceneView:refreshPlayerAndCamera()
    local distanceX = math.abs(self.camera:getPositionX() - self.player:getPositionX()) 
    local distanceY = math.abs(self.camera:getPositionY() - self.player:getPositionY())

    if distanceX > GameUtil:VISIBLE_WIDTH()/4 then 
       --需要判断方向
       if self.player:getPositionX() < self.camera:getPositionX() then  --在左边
       	  self:setCameraPosX(-1,self.speed*10)
       else                                                             --在右边
       	  self:setCameraPosX(1,self.speed*10)
       end
       
    end

    if distanceY > GameUtil:VISIBLE_HEIGHT()/4 then 
       --需要判断方向
       if self.player:getPositionY() < self.camera:getPositionY() then  --在下边
       	  self:setCameraPosY(-1,self.speed*10)
       else                                                             --在上边
       	  self:setCameraPosY(1,self.speed*10)
       end
    end

    -- dump(distanceX) 
    -- dump(distanceY) 
end


function OriginalSceneView:onTouchBegan( x,y )
	print("-----onTouchBegan-------")
    print(x,y)
    dump(self.map:convertToNodeSpace(cc.p(x,y)))
    dump(self.map:convertToNodeSpaceAR(cc.p(x,y)))
    dump(self.map:convertToWorldSpaceAR(cc.p(x,y)))
    dump(self.map:convertToWorldSpace(cc.p(x,y)))
 
end

function OriginalSceneView:onTouchMoved( x,y )
	print("-----onTouchMoved-------")
    print(x,y)
    dump(self.map:convertToNodeSpace(cc.p(x,y)))
end

function OriginalSceneView:onTouchEnded( x,y,exJudge )
    print("-----onTouchEnded-------")
    print(x,y)
    dump(self.map:convertToNodeSpace(cc.p(x,y)))
end


function OriginalSceneView:onEnter()
	OriginalSceneView.super.onEnter(self)
    print("OriginalSceneView onEnter")

    --self:initScene()
end

function OriginalSceneView:onExit()
	OriginalSceneView.super.onExit(self)
    print("OriginalSceneView onExit")
end

function OriginalSceneView.open()
	local view = OriginalSceneView.new()
	view:initScene()
	--这里以后肯定要进行特殊处理
end

