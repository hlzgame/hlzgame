--
-- Author: HLZ
-- Date: 2016-01-06 10:00:33
-- 功能重写类




--获取文件的扩展名
function getExtension(str)
    return str:match(".+%.(%w+)$")
end
