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
    self.guiBackgroundNode = createGUINode(res.RES_BACKGROUND_ORIGINAL)
    self.guiBackgroundNode:setName("self.guiNode")
    --背景层是不需要动的
    self:addChild(self.guiBackgroundNode)
    --self.guiNode:setVisible(false)
    --dump(cc.Camera:getDefaultCamera():getPosition())


    --加载地图
	self.map = self:createTMXTM(ORIGINAL_SCENCE_TMX)
	self.map:setName("self.map")
    self:addChild(self.map,5)
    self.map:setAnchorPoint(cc.p(0,0))    
      
    self.impactLayer = self:getLayer(IMPACT_LAYER)
    --self.backGroundLayer = self:getLayer(BACKGROUND_LAYER)
    self.impactLayer:setVisible(false)

    self.player = PlayerView.new()
    self.map:addChild(self.player,10)  

    self.initPlayerPos = self:positionForTileCoord(self.map,cc.p(12,28))

    self.player:setPosition(self.initPlayerPos)

    if self.updateBattle ~= nil  then
        g_scheduler:unscheduleScriptEntry(self.updateBattle);
        self.updateBattle = nil 
    end

    self.backgroundCamera = self:setBackgroundCamera(self.guiBackgroundNode)
    self.mapCamera = self:setMapCamera(self.map)
 
    --开启触摸
    self:initKeyBoardListener()

    
end


--这里还有问题 =。= 计算出错
function OriginalSceneView:refreshPlayerAndCamera(speed)
    if speed ~= 0 then 
    	return 
    end
	local mapCameraPosX = self.mapCamera:getPositionX()
	local mapCameraPoxY = self.mapCamera:getPositionY()
    local distanceX = math.abs(mapCameraPosX - self.player:getPositionX()) 
    local distanceY = math.abs(mapCameraPoxY - self.player:getPositionY())

    if distanceX > GameUtil:VISIBLE_WIDTH()/4 then 
       --需要判断方向
       if self.player:getPositionX() < mapCameraPosX then  --在左边
       	  self:setCameraPosX(-1,speed)
       else                                                             --在右边
       	  self:setCameraPosX(1,speed)
       end
       
    end

    if distanceY > GameUtil:VISIBLE_HEIGHT()/4 then 
       --需要判断方向
       if self.player:getPositionY() < mapCameraPoxY then  --在下边
       	  self:setCameraPosY(-1,speed)
       else                                                             --在上边
       	  self:setCameraPosY(1,speed)
       end
    end

    -- dump(distanceX) 
    -- dump(distanceY) 
end


-- function OriginalSceneView:onTouchBegan( x,y )
-- 	print("-----onTouchBegan-------")
--     print(x,y)
--     dump(self.map:convertToNodeSpace(cc.p(x,y)))
--     dump(self.map:convertToNodeSpaceAR(cc.p(x,y)))
--     dump(self.map:convertToWorldSpaceAR(cc.p(x,y)))
--     dump(self.map:convertToWorldSpace(cc.p(x,y)))
 
-- end

-- function OriginalSceneView:onTouchMoved( x,y )
-- 	print("-----onTouchMoved-------")
--     print(x,y)
--     dump(self.map:convertToNodeSpace(cc.p(x,y)))
-- end

-- function OriginalSceneView:onTouchEnded( x,y,exJudge )
--     print("-----onTouchEnded-------")
--     print(x,y)
--     dump(self.map:convertToNodeSpace(cc.p(x,y)))
-- end

function OriginalSceneView:pressedLeftBtnListener()
	self.speedLR = -0.5
    self.player:setScaleX(-1)
    local func = function ( )
    	self.player:setPositionX(self.player:getPositionX() + self.speedLR*10) 
    	local speed = self.speedLR*10
    	self:refreshPlayerAndCamera(speed)
    end

    if self.leftMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.leftMoveHandler)
       self.leftMoveHandler = nil 
    end
	
	self.leftMoveHandler = g_scheduler:scheduleScriptFunc(func,0,false) 
end

function TiledMapScene:pressedRightBtnListener()
    self.speedLR = 0.5
     self.player:setScaleX(1)
	local func = function ( )
    	self.player:setPositionX(self.player:getPositionX() + self.speedLR*10) 
    	local speed = self.speedLR*10
    	self:refreshPlayerAndCamera(speed)
    end

    if self.rightMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.rightMoveHandler)
       self.rightMoveHandler = nil 
    end
	
	self.rightMoveHandler = g_scheduler:scheduleScriptFunc(func,0,false) 
end
function TiledMapScene:pressedUpBtnListener()
    self.speedUD = 0.5
    	local func = function ( )
    	self.player:setPositionY(self.player:getPositionY() + self.speedUD*10) 
    	local speed = self.speedUD*10
    	self:refreshPlayerAndCamera(speed)
    end

    if self.upMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.upMoveHandler)
       self.upMoveHandler = nil 
    end
	
	self.upMoveHandler = g_scheduler:scheduleScriptFunc(func,0,false)
end
function TiledMapScene:pressedDownBtnListener()
    self.speedUD = -0.5
    local func = function ( )
    	self.player:setPositionY(self.player:getPositionY() + self.speedUD*10) 
    	local speed = self.speedUD*10
    	self:refreshPlayerAndCamera(speed)
    end

    if self.downMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.downMoveHandler)
       self.downMoveHandler = nil 
    end
	
	self.downMoveHandler = g_scheduler:scheduleScriptFunc(func,0,false)
end



--松开事件
function TiledMapScene:releasedLeftBtnListener()
	if self.leftMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.leftMoveHandler)
       self.leftMoveHandler = nil 
    end
end
function TiledMapScene:releasedRightBtnListener()
    if self.rightMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.rightMoveHandler)
       self.rightMoveHandler = nil 
    end
end
function TiledMapScene:releasedUpBtnListener()
    if self.upMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.upMoveHandler)
       self.upMoveHandler = nil 
    end
end
function TiledMapScene:releasedDownBtnListener()
    if self.downMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.downMoveHandler)
       self.downMoveHandler = nil 
    end
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

