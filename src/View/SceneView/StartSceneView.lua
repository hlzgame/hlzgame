--
-- Author: HLZ
-- Date: 2015-12-29 14:56:16
-- 开始菜单场景

StartSceneView = class("StartSceneView",function()
	return cc.Scene:create()
end)



function StartSceneView:ctor()
	
end

function StartSceneView:initScene()
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self)
    else
        cc.Director:getInstance():runWithScene(self)
    end
end


function StartSceneView:createScene()

	self:initScene()

    self.layer = cc.Layer:create()
    self:addChild(self.layer)

	self.guiNode = createGUINode(res.RES_START_GAME)
	self.layer:addChild(self.guiNode,10)


end

function StartSceneView:onEnter()
    print("createScene")
	--self:createScene()
end

function StartSceneView:onExit()

end

function StartSceneView.open()
	local view = StartSceneView.new()
	view:createScene()
	--这里以后肯定要进行特殊处理
end

