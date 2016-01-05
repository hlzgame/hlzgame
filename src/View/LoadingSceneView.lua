--
-- Author: HLZ
-- Date: 2015-12-29 14:56:16
-- 预加载场景

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

    local layer = cc.Layer:create()
    self:addChild(layer)
	local sprite = cc.Sprite:create("13.png")
	sprite:setPosition(cc.p(1136/2,320))
	layer:addChild(sprite,1)

	local sprite2 = cc.Sprite:create("23.png")
	sprite2:setPosition(cc.p(1136/2,400))
	layer:addChild(sprite2,1)

	local label = cc.Label:createWithSystemFont("新的旅途开始了！","微软雅黑",22)
	label:setPosition(cc.p(1136/2,500))
	layer:addChild(label,2)


	self.guiNode = createGUINode(res.RES_START_GAME)
	self:addChild(self.guiNode,10)


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

