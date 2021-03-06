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

    self.player = PlayerView.new(self)
    self.map:addChild(self.player,10) 

    self.player:openOrColseGravity(true)
 
    --初始位置
    self.initPlayerPos = self:positionForTileCoord(cc.p(60,28))

    self.player:setPosition(self.initPlayerPos)

    if self.updateBattle ~= nil  then
        g_scheduler:unscheduleScriptEntry(self.updateBattle);
        self.updateBattle = nil 
    end
    
    --添加摄像机 （背景相机 和 地图相机）
    self.backgroundCamera = self:setBackgroundCamera(self.guiBackgroundNode)
    self.mapCamera = self:setMapCamera(self.map,self.player)
    
 
    --开启键盘控制（win32版本使用）
    if g_game:getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then 
       self:initKeyBoardListener()
    end
    
end

function OriginalSceneView:pressedLeftBtnListener()
    self.player:toLeft()
end

function OriginalSceneView:pressedRightBtnListener()
    self.player:toRight() 
end
function OriginalSceneView:pressedUpBtnListener()
    --[[按住向上有这几种状态
           1、跳跃状态
           2、向上爬动状态

    --]]
    local isJump = true
    if isJump == true then 
        --self:refershPlayerPosInfo(self.player,TiledMapScene.JUMP)
        self.player:doEvent("isJump")
    elseif isJump == false then
        local func = function ( )
            --self:refershPlayerPosInfo(self.player,TiledMapScene.UP)
            self.player:refershPos(TiledMapScene.UP)
        end

        if self.upMoveHandler ~= nil then 
           g_scheduler:unscheduleScriptEntry(self.upMoveHandler)
           self.upMoveHandler = nil 
        end
        
        self.upMoveHandler = g_scheduler:scheduleScriptFunc(func,0,false)
    end
        --todo
    
end
function OriginalSceneView:pressedDownBtnListener()
    local func = function ( )
    	--self:refershPlayerPosInfo(self.player,TiledMapScene.DOWN)
        self.player:refershPos(TiledMapScene.DOWN)
    end

    if self.downMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.downMoveHandler)
       self.downMoveHandler = nil 
    end
	
	self.downMoveHandler = g_scheduler:scheduleScriptFunc(func,0,false)
end



--松开事件
function OriginalSceneView:releasedLeftBtnListener()
	self.player:removeLeftMoveHandler()
end
function OriginalSceneView:releasedRightBtnListener()
    self.player:removeRightMoveHandler()
end
function OriginalSceneView:releasedUpBtnListener()
    if self.upMoveHandler ~= nil then 
       g_scheduler:unscheduleScriptEntry(self.upMoveHandler)
       self.upMoveHandler = nil 
    end
end
function OriginalSceneView:releasedDownBtnListener()
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

