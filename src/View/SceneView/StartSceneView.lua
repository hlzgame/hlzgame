--
-- Author: HLZ
-- Date: 2015-12-29 14:56:16
-- 开始菜单场景
require("Utils.EventScene")

StartSceneView = class("StartSceneView",EventScene)
--[[
    继承与 EventScene类，所以ctor onEnter onExit 都需要super
--]]

function StartSceneView:ctor()
	StartSceneView.super.ctor(self)
	
end

function StartSceneView:initScene()

	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self)
    else
        cc.Director:getInstance():runWithScene(self)
    end
    self:initEvent()
end

function StartSceneView:initEvent()
    self:registerEvent(TEST_EVENT_RETURN,function(event)
        print("TEST_EVENT_RETURN")
   end)
end


function StartSceneView:createScene()

	self:initScene()

    self.layer = cc.Layer:create()
    self:addChild(self.layer)

	self.guiNode = createGUINode(res.RES_START_GAME)
	self.layer:addChild(self.guiNode,10)

	self.btnStart = self.guiNode:getChildByName("Button_2")
	self.btnStart:addTouchEventListener(function(sender,event)
		if event == ccui.TouchEventType.ended then 
		   print("self.btnStart")
		   g_EventDispatch:dispatchEvent(TEST_EVENT_RETURN)
	    end 
	end)

	--logDebug("---")


end

function StartSceneView:onEnter()
	StartSceneView.super.onEnter(self)
    print("onEnter")
end

function StartSceneView:onExit()
	StartSceneView.super.onExit(self)
    print("onExit")
end

function StartSceneView.open()
	local view = StartSceneView.new()
	view:createScene()
	--这里以后肯定要进行特殊处理
end

