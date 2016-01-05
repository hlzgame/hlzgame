--
-- Author: HLZ
-- Date: 2015-12-29 14:56:16
-- 预加载场景

require("View.SceneView.StartSceneView")

LoadingSceneView = class("LoadingSceneView",function()
	return cc.Scene:create()
end)



function LoadingSceneView:ctor()
	
end

function LoadingSceneView:initScene()
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self)
    else
        cc.Director:getInstance():runWithScene(self)
    end
end


function LoadingSceneView:createScene()

	self:initScene()

 --    self.layer = cc.Layer:create()
 --    self:addChild(self.layer)

	-- self.guiNode = createGUINode(res.RES_START_GAME)
	-- self.layer:addChild(self.guiNode,10)
    StartSceneView.open()

end

function LoadingSceneView:onEnter()
    print("createScene") 
	--self:createScene()
end

function LoadingSceneView:onExit()

end

function LoadingSceneView.open()
	local view = LoadingSceneView.new()
	view:createScene()
	--这里以后肯定要进行特殊处理
end
