--[[
    collectgarbage (opt [, arg])
　　功能：是垃圾收集器的通用接口，用于操作垃圾收集器
　　参数：
　　opt：操作方法标志
　　"Stop": 停止垃圾收集器
　　"Restart": 重启垃圾收集器
　　"Collect": 执行一次全垃圾收集循环
　　"Count": 返回当前Lua中使用的内存量(以KB为单位)
　　"Step": 单步执行一个垃圾收集. 步长 "Size" 由参数arg指定　(大型的值需要多步才能完成)，如果要准确指定步长，需要多次实验以达最优效果。如果步长完成一次收集循环，将返回True
　　"Setpause": 设置 arg/100 的值作为暂定收集的时长
　　"Setstepmul": 设置 arg/100 的值，作为步长的增幅(即新步长=旧步长*arg/100)
    ]]

    collectgarbage("collect");
    -- avoid memory leak
    collectgarbage("setpause", 100);
    collectgarbage("setstepmul", 5000);